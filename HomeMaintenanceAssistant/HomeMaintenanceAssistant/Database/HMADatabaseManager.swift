//
//  HMADatabaseManager.swift
//  HomeMaintenanceAssistant
//
//  Thin SQLite (libsqlite3) wrapper. Owns schema creation, first-run seeding
//  and all CRUD used by the view models. Fully offline; no networking.
//

import Foundation
import SQLite3

/// SQLite needs this transient-destructor marker for bound text columns.
private let HMA_SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

final class HMADatabaseManager {

    static let shared = HMADatabaseManager()

    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.hma.database.serial")
    private(set) var dataVersion = "1.0.0"

    private init() {}

    // MARK: - Lifecycle

    /// Opens the store, creates tables and seeds bundled content on first run.
    func HMAprepareStore() {
        queue.sync {
            let path = HMAdatabaseURL().path
            if sqlite3_open(path, &db) != SQLITE_OK {
                assertionFailure("HMA: unable to open SQLite store at \(path)")
                return
            }
            sqlite3_exec(db, "PRAGMA foreign_keys = ON;", nil, nil, nil)
            HMAcreateSchema()
            if HMAcountRows(in: "areas") == 0 {
                HMAseedBundledContent()
            }
        }
    }

    private func HMAdatabaseURL() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory,
                                           in: .userDomainMask).first!
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir,
                                                     withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("hma_home_maintenance.sqlite")
    }

    // MARK: - Schema

    private func HMAcreateSchema() {
        let statements = [
            """
            CREATE TABLE IF NOT EXISTS areas (
                id   INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                icon TEXT NOT NULL
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS tasks (
                id          INTEGER PRIMARY KEY,
                area_id     INTEGER NOT NULL,
                title       TEXT NOT NULL,
                description TEXT NOT NULL,
                difficulty  TEXT NOT NULL,
                frequency   TEXT NOT NULL,
                minutes     INTEGER NOT NULL,
                tools       TEXT NOT NULL,
                safety      TEXT NOT NULL,
                procedure   TEXT NOT NULL,
                FOREIGN KEY(area_id) REFERENCES areas(id)
            );
            """,
            """
            CREATE TABLE IF NOT EXISTS records (
                id      INTEGER PRIMARY KEY AUTOINCREMENT,
                task_id INTEGER NOT NULL,
                date    INTEGER NOT NULL,
                result  TEXT NOT NULL,
                notes   TEXT NOT NULL DEFAULT '',
                FOREIGN KEY(task_id) REFERENCES tasks(id)
            );
            """
        ]
        for sql in statements {
            sqlite3_exec(db, sql, nil, nil, nil)
        }
    }

    // MARK: - Generic helpers

    private func HMAcountRows(in table: String) -> Int {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM \(table);", -1, &stmt, nil) == SQLITE_OK
        else { return 0 }
        return sqlite3_step(stmt) == SQLITE_ROW ? Int(sqlite3_column_int(stmt, 0)) : 0
    }

    private func HMAtext(_ stmt: OpaquePointer?, _ index: Int32) -> String {
        guard let c = sqlite3_column_text(stmt, index) else { return "" }
        return String(cString: c)
    }

    // MARK: - Areas

    func HMAfetchAreas() -> [HMAArea] {
        queue.sync {
            var result: [HMAArea] = []
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            let sql = "SELECT id, name, icon FROM areas ORDER BY id;"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return result }
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(HMAArea(id: Int(sqlite3_column_int(stmt, 0)),
                                      name: HMAtext(stmt, 1),
                                      icon: HMAtext(stmt, 2)))
            }
            return result
        }
    }

    // MARK: - Tasks

    private func HMAmapTask(_ stmt: OpaquePointer?) -> HMATask {
        HMATask(id: Int(sqlite3_column_int(stmt, 0)),
                areaId: Int(sqlite3_column_int(stmt, 1)),
                title: HMAtext(stmt, 2),
                detail: HMAtext(stmt, 3),
                difficulty: HMADifficulty.HMAfrom(HMAtext(stmt, 4)),
                frequency: HMAFrequency.HMAfrom(HMAtext(stmt, 5)),
                estimatedMinutes: Int(sqlite3_column_int(stmt, 6)),
                tools: HMAtext(stmt, 7),
                safety: HMAtext(stmt, 8),
                procedure: HMAtext(stmt, 9))
    }

    private static let HMAtaskColumns =
        "id, area_id, title, description, difficulty, frequency, minutes, tools, safety, procedure"

    func HMAfetchTasks(areaId: Int? = nil) -> [HMATask] {
        queue.sync {
            var result: [HMATask] = []
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            var sql = "SELECT \(Self.HMAtaskColumns) FROM tasks"
            if areaId != nil { sql += " WHERE area_id = ?" }
            sql += " ORDER BY title;"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return result }
            if let areaId = areaId { sqlite3_bind_int(stmt, 1, Int32(areaId)) }
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(HMAmapTask(stmt))
            }
            return result
        }
    }

    func HMAfetchTask(id: Int) -> HMATask? {
        queue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            let sql = "SELECT \(Self.HMAtaskColumns) FROM tasks WHERE id = ?;"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
            sqlite3_bind_int(stmt, 1, Int32(id))
            return sqlite3_step(stmt) == SQLITE_ROW ? HMAmapTask(stmt) : nil
        }
    }

    func HMAtaskCount() -> Int { queue.sync { HMAcountRows(in: "tasks") } }

    // MARK: - Records

    private func HMAmapRecord(_ stmt: OpaquePointer?) -> HMARecord {
        var record = HMARecord(id: Int(sqlite3_column_int(stmt, 0)),
                               taskId: Int(sqlite3_column_int(stmt, 1)),
                               date: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2)),
                               result: HMARecordResult(rawValue: HMAtext(stmt, 3)) ?? .completed,
                               notes: HMAtext(stmt, 4))
        record.taskTitle = HMAtext(stmt, 5)
        record.areaName = HMAtext(stmt, 6)
        return record
    }

    private static let HMArecordSelect = """
        SELECT r.id, r.task_id, r.date, r.result, r.notes,
               t.title, a.name
        FROM records r
        LEFT JOIN tasks t ON t.id = r.task_id
        LEFT JOIN areas a ON a.id = t.area_id
        """

    func HMAfetchRecords() -> [HMARecord] {
        queue.sync {
            var result: [HMARecord] = []
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            let sql = Self.HMArecordSelect + " ORDER BY r.date DESC;"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return result }
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(HMAmapRecord(stmt))
            }
            return result
        }
    }

    /// Most recent record date per task, used to compute schedule status.
    func HMAlastDoneByTask() -> [Int: Date] {
        queue.sync {
            var map: [Int: Date] = [:]
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            let sql = """
                SELECT task_id, MAX(date) FROM records
                WHERE result = 'Completed' GROUP BY task_id;
                """
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return map }
            while sqlite3_step(stmt) == SQLITE_ROW {
                map[Int(sqlite3_column_int(stmt, 0))] =
                    Date(timeIntervalSince1970: sqlite3_column_double(stmt, 1))
            }
            return map
        }
    }

    @discardableResult
    func HMAinsertRecord(taskId: Int, date: Date, result: HMARecordResult, notes: String) -> Bool {
        queue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            let sql = "INSERT INTO records (task_id, date, result, notes) VALUES (?, ?, ?, ?);"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
            sqlite3_bind_int(stmt, 1, Int32(taskId))
            sqlite3_bind_double(stmt, 2, date.timeIntervalSince1970)
            sqlite3_bind_text(stmt, 3, result.rawValue, -1, HMA_SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 4, notes, -1, HMA_SQLITE_TRANSIENT)
            return sqlite3_step(stmt) == SQLITE_DONE
        }
    }

    @discardableResult
    func HMAupdateRecord(id: Int, date: Date, result: HMARecordResult, notes: String) -> Bool {
        queue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            let sql = "UPDATE records SET date = ?, result = ?, notes = ? WHERE id = ?;"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
            sqlite3_bind_double(stmt, 1, date.timeIntervalSince1970)
            sqlite3_bind_text(stmt, 2, result.rawValue, -1, HMA_SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, notes, -1, HMA_SQLITE_TRANSIENT)
            sqlite3_bind_int(stmt, 4, Int32(id))
            return sqlite3_step(stmt) == SQLITE_DONE
        }
    }

    @discardableResult
    func HMAdeleteRecord(id: Int) -> Bool {
        queue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, "DELETE FROM records WHERE id = ?;", -1, &stmt, nil) == SQLITE_OK
            else { return false }
            sqlite3_bind_int(stmt, 1, Int32(id))
            return sqlite3_step(stmt) == SQLITE_DONE
        }
    }

    func HMArecordCount() -> Int { queue.sync { HMAcountRows(in: "records") } }

    // MARK: - Seeding

    private func HMAseedBundledContent() {
        sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil)

        // Areas
        for area in HMASeedData.areas {
            var stmt: OpaquePointer?
            let sql = "INSERT INTO areas (id, name, icon) VALUES (?, ?, ?);"
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(area.id))
                sqlite3_bind_text(stmt, 2, area.name, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 3, area.icon, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }

        // Tasks
        for task in HMASeedData.HMAbuildTasks() {
            var stmt: OpaquePointer?
            let sql = """
                INSERT INTO tasks
                (id, area_id, title, description, difficulty, frequency, minutes, tools, safety, procedure)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(task.id))
                sqlite3_bind_int(stmt, 2, Int32(task.areaId))
                sqlite3_bind_text(stmt, 3, task.title, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 4, task.detail, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 5, task.difficulty.rawValue, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 6, task.frequency.rawValue, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_int(stmt, 7, Int32(task.estimatedMinutes))
                sqlite3_bind_text(stmt, 8, task.tools, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 9, task.safety, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 10, task.procedure, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }

        // Records
        for record in HMASeedData.HMAbuildRecords() {
            var stmt: OpaquePointer?
            let sql = "INSERT INTO records (task_id, date, result, notes) VALUES (?, ?, ?, ?);"
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(record.taskId))
                sqlite3_bind_double(stmt, 2, record.date.timeIntervalSince1970)
                sqlite3_bind_text(stmt, 3, record.result.rawValue, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 4, record.notes, -1, HMA_SQLITE_TRANSIENT)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }

        sqlite3_exec(db, "COMMIT;", nil, nil, nil)
    }
}
