//
//  Models.swift
//  Bearing Atlas Pro
//
//  Plain data structs mirroring the SQLite schema.
//  All tables use INTEGER PRIMARY KEYS. Every child links via fault_id.
//

import Foundation

struct BAEPFault {
    let id: Int
    let name: String
    let system: String
    let severity: String
    let description: String
}

struct BAEPKnowledgeArticle {
    let id: Int
    let faultId: Int
    let title: String
    let overview: String
    let causes: String
    let symptoms: String
    let inspection: String
    let maintenance: String
}

struct BAEPMaintenanceTask {
    let id: Int
    let faultId: Int
    let name: String
    let tools: String
    let safety: String
    let steps: String
    let expectedResult: String
}

struct BAEPServiceRecord {
    let id: Int
    let faultId: Int
    let motorName: String
    let diagnosisResult: String
    let action: String
    let result: String
    let date: String
    let notes: String
}
