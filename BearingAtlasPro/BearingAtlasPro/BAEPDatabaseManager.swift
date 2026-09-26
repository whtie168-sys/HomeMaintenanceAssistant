//
//  BAEPDatabaseManager.swift
//  Bearing Atlas Pro
//
//  SQLite ONLY. 100% offline. No network.
//  Four tables, all INTEGER PRIMARY KEY, children linked by fault_id.
//  Seeds the fixed 20 faults + linked knowledge + maintenance on first launch.
//

import Foundation
import SQLite3

// SQLite needs a transient destructor for bound text on 64-bit.
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

final class BAEPDatabaseManager {

    static let shared = BAEPDatabaseManager()

    private var db: OpaquePointer?

    private init() {
        open()
        createTables()
        seedIfNeeded()
    }

    deinit {
        sqlite3_close(db)
    }

    // MARK: - Setup

    private func dbURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("bearing_atlas.sqlite")
    }

    private func open() {
        if sqlite3_open(dbURL().path, &db) != SQLITE_OK {
            assertionFailure("Unable to open SQLite database")
        }
        sqlite3_exec(db, "PRAGMA foreign_keys = ON;", nil, nil, nil)
    }

    private func createTables() {
        let statements = [
            """
            CREATE TABLE IF NOT EXISTS faults (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                system TEXT NOT NULL,
                severity TEXT NOT NULL,
                description TEXT NOT NULL
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS knowledge_articles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                fault_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                overview TEXT NOT NULL,
                causes TEXT NOT NULL,
                symptoms TEXT NOT NULL,
                inspection TEXT NOT NULL,
                maintenance TEXT NOT NULL,
                FOREIGN KEY(fault_id) REFERENCES faults(id)
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS maintenance_tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                fault_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                tools TEXT NOT NULL,
                safety TEXT NOT NULL,
                steps TEXT NOT NULL,
                expected_result TEXT NOT NULL,
                FOREIGN KEY(fault_id) REFERENCES faults(id)
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                fault_id INTEGER NOT NULL,
                motor_name TEXT NOT NULL,
                diagnosis_result TEXT NOT NULL,
                action TEXT NOT NULL,
                result TEXT NOT NULL,
                date TEXT NOT NULL,
                notes TEXT NOT NULL,
                FOREIGN KEY(fault_id) REFERENCES faults(id)
            );
            """,
        ]
        for sql in statements {
            sqlite3_exec(db, sql, nil, nil, nil)
        }
    }

    // MARK: - Seeding

    private func seedIfNeeded() {
        guard countRows(in: "faults") == 0 else { return }

        sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil)

        for fault in BAEPSeedData.faults {
            let sql = "INSERT INTO faults (name, system, severity, description) VALUES (?, ?, ?, ?);"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, fault.0, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 2, fault.1, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 3, fault.2, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 4, fault.3, -1, SQLITE_TRANSIENT)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }

        for a in BAEPSeedData.articles {
            let sql = """
                INSERT INTO knowledge_articles (fault_id, title, overview, causes, symptoms, inspection, maintenance)
                VALUES (?, ?, ?, ?, ?, ?, ?);
                """
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(a.0))
                sqlite3_bind_text(stmt, 2, a.1, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 3, a.2, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 4, a.3, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 5, a.4, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 6, a.5, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 7, a.6, -1, SQLITE_TRANSIENT)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }

        for t in BAEPSeedData.tasks {
            let sql = """
                INSERT INTO maintenance_tasks (fault_id, name, tools, safety, steps, expected_result)
                VALUES (?, ?, ?, ?, ?, ?);
                """
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(t.0))
                sqlite3_bind_text(stmt, 2, t.1, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 3, t.2, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 4, t.3, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 5, t.4, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 6, t.5, -1, SQLITE_TRANSIENT)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }

        sqlite3_exec(db, "COMMIT;", nil, nil, nil)
    }

    private func countRows(in table: String) -> Int {
        var stmt: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM \(table);", -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)
        return count
    }

    // MARK: - Read helpers

    private func text(_ stmt: OpaquePointer?, _ index: Int32) -> String {
        guard let c = sqlite3_column_text(stmt, index) else { return "" }
        return String(cString: c)
    }

    // MARK: - Faults

    func fetchFaults() -> [BAEPFault] {
        var result: [BAEPFault] = []
        let sql = "SELECT id, name, system, severity, description FROM faults ORDER BY id;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(BAEPFault(
                    id: Int(sqlite3_column_int(stmt, 0)),
                    name: text(stmt, 1),
                    system: text(stmt, 2),
                    severity: text(stmt, 3),
                    description: text(stmt, 4)
                ))
            }
        }
        sqlite3_finalize(stmt)
        return result
    }

    // MARK: - Knowledge (linked by fault_id)

    func fetchArticle(faultId: Int) -> BAEPKnowledgeArticle? {
        let sql = """
            SELECT id, fault_id, title, overview, causes, symptoms, inspection, maintenance
            FROM knowledge_articles WHERE fault_id = ? LIMIT 1;
            """
        var stmt: OpaquePointer?
        var article: BAEPKnowledgeArticle?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(faultId))
            if sqlite3_step(stmt) == SQLITE_ROW {
                article = BAEPKnowledgeArticle(
                    id: Int(sqlite3_column_int(stmt, 0)),
                    faultId: Int(sqlite3_column_int(stmt, 1)),
                    title: text(stmt, 2),
                    overview: text(stmt, 3),
                    causes: text(stmt, 4),
                    symptoms: text(stmt, 5),
                    inspection: text(stmt, 6),
                    maintenance: text(stmt, 7)
                )
            }
        }
        sqlite3_finalize(stmt)
        return article
    }

    // MARK: - Maintenance (linked by fault_id)

    func fetchTask(faultId: Int) -> BAEPMaintenanceTask? {
        let sql = """
            SELECT id, fault_id, name, tools, safety, steps, expected_result
            FROM maintenance_tasks WHERE fault_id = ? LIMIT 1;
            """
        var stmt: OpaquePointer?
        var task: BAEPMaintenanceTask?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(faultId))
            if sqlite3_step(stmt) == SQLITE_ROW {
                task = BAEPMaintenanceTask(
                    id: Int(sqlite3_column_int(stmt, 0)),
                    faultId: Int(sqlite3_column_int(stmt, 1)),
                    name: text(stmt, 2),
                    tools: text(stmt, 3),
                    safety: text(stmt, 4),
                    steps: text(stmt, 5),
                    expectedResult: text(stmt, 6)
                )
            }
        }
        sqlite3_finalize(stmt)
        return task
    }

    // MARK: - Records (linked by fault_id)

    func fetchRecords() -> [BAEPServiceRecord] {
        var result: [BAEPServiceRecord] = []
        let sql = """
            SELECT id, fault_id, motor_name, diagnosis_result, action, result, date, notes
            FROM records ORDER BY id DESC;
            """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(BAEPServiceRecord(
                    id: Int(sqlite3_column_int(stmt, 0)),
                    faultId: Int(sqlite3_column_int(stmt, 1)),
                    motorName: text(stmt, 2),
                    diagnosisResult: text(stmt, 3),
                    action: text(stmt, 4),
                    result: text(stmt, 5),
                    date: text(stmt, 6),
                    notes: text(stmt, 7)
                ))
            }
        }
        sqlite3_finalize(stmt)
        return result
    }

    func fetchRecords(faultId: Int) -> [BAEPServiceRecord] {
        return fetchRecords().filter { $0.faultId == faultId }
    }

    @discardableResult
    func insertRecord(faultId: Int, motorName: String, diagnosisResult: String,
                      action: String, result: String, date: String, notes: String) -> Bool {
        let sql = """
            INSERT INTO records (fault_id, motor_name, diagnosis_result, action, result, date, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?);
            """
        var stmt: OpaquePointer?
        var ok = false
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(faultId))
            sqlite3_bind_text(stmt, 2, motorName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, diagnosisResult, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 4, action, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 5, result, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 6, date, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 7, notes, -1, SQLITE_TRANSIENT)
            ok = sqlite3_step(stmt) == SQLITE_DONE
        }
        sqlite3_finalize(stmt)
        return ok
    }

    @discardableResult
    func deleteRecord(id: Int) -> Bool {
        let sql = "DELETE FROM records WHERE id = ?;"
        var stmt: OpaquePointer?
        var ok = false
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(id))
            ok = sqlite3_step(stmt) == SQLITE_DONE
        }
        sqlite3_finalize(stmt)
        return ok
    }

    // MARK: - Stats (Settings, traceable to records/faults)

    func recordCount() -> Int { countRows(in: "records") }
    func faultCount() -> Int { countRows(in: "faults") }
}
