//
//  MBAutomationDatabase.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import SQLite3

class MBAutomationDatabase: NSObject {
    
    // MARK: - DB Creation
    
    static let dbQueue = DispatchQueue(label: "mb_automation_db_queue")
    
    static func setupTables() {
        guard let db = openDatabase() else {
            return
        }
        
        let createViewTableString = "CREATE TABLE IF NOT EXISTS view (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, view TEXT, metadata TEXT, timestamp REAL);"
        var createViewTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewTableString, -1, &createViewTableStatement, nil) == SQLITE_OK {
            sqlite3_step(createViewTableStatement)
        }
        sqlite3_finalize(createViewTableStatement)
        
        let createEventTableString = "CREATE TABLE IF NOT EXISTS event (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, event TEXT, name TEXT, metadata TEXT, timestamp REAL);"
        var createEventTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createEventTableString, -1, &createEventTableStatement, nil) == SQLITE_OK {
            sqlite3_step(createEventTableStatement)
        }
        sqlite3_finalize(createEventTableStatement)
        
        sqlite3_close(db)
    }
    
    // MARK: - Save
    
    static func saveView(_ view: MBAutomationView) {
        dbQueue.async {
            guard let db = openDatabase() else {
                return
            }
            
            let metadataString = jsonString(fromDictionary: view.metadata)
            
            let insertStatementString = "INSERT INTO view (view, metadata, timestamp) VALUES (?, ?, ?);"
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (view.view as NSString?)?.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, (metadataString as NSString?)?.utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 3, view.timestamp.timeIntervalSince1970)
                
                sqlite3_step(insertStatement)
            }
            
            sqlite3_finalize(insertStatement)
            sqlite3_close(db)
        }
    }
    
    static func saveEvent(_ event: MBAutomationEvent) {
        dbQueue.async {
            guard let db = openDatabase() else {
                return
            }
            
            let metadataString = jsonString(fromDictionary: event.metadata)
            
            let insertStatementString = "INSERT INTO event (event, name, metadata, timestamp) VALUES (?, ?, ?, ?);"
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (event.event as NSString?)?.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, (event.name as NSString?)?.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, (metadataString as NSString?)?.utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 4, event.timestamp.timeIntervalSince1970)
                
                sqlite3_step(insertStatement)
            }
            
            sqlite3_finalize(insertStatement)
            sqlite3_close(db)
        }
    }
    
    private static func jsonString(fromDictionary dictionary: [String: Any]?) -> String? {
        guard let dictionary = dictionary else {
            return nil
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Retrieve
    
    static func views(completion: @escaping ([MBAutomationView]?) -> Void) {
        dbQueue.async {
            guard let db = openDatabase() else {
                return
            }
            
            var views = [MBAutomationView]()
            
            let query = "SELECT id, view, metadata, timestamp FROM view ORDER BY timestamp ASC"
            var queryStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let viewId = sqlite3_column_int(queryStatement, 0)
                    let viewName = stringForCString(sqlite3_column_text(queryStatement, 1)) ?? ""
                    var metadata: [String: Any]?
                    if let metadataString = sqlite3_column_text(queryStatement, 2) {
                        metadata = jsonDictionaryForCString(metadataString)
                    }
                    let timeStamp = sqlite3_column_double(queryStatement, 3)
                    
                    let view = MBAutomationView(id: Int(viewId),
                                                view: viewName,
                                                metadata: metadata,
                                                timestamp: timeStamp)
                    views.append(view)
                }
            }
            
            sqlite3_finalize(queryStatement)
            sqlite3_close(db)
            
            completion(views)
        }
    }
    
    static func events(completion: @escaping ([MBAutomationEvent]?) -> Void) {
        dbQueue.async {
            guard let db = openDatabase() else {
                return
            }
            
            var events = [MBAutomationEvent]()
            
            let query = "SELECT id, event, name, metadata, timestamp FROM event ORDER BY timestamp ASC"
            var queryStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let eventId = sqlite3_column_int(queryStatement, 0)
                    let eventEvent = stringForCString(sqlite3_column_text(queryStatement, 1)) ?? ""
                    var eventName: String?
                    if let eventNameString = sqlite3_column_text(queryStatement, 2) {
                        eventName = stringForCString(eventNameString)
                    }
                    var metadata: [String: Any]?
                    if let metadataString = sqlite3_column_text(queryStatement, 3) {
                        metadata = jsonDictionaryForCString(metadataString)
                    }
                    let timeStamp = sqlite3_column_double(queryStatement, 4)
                    
                    let event = MBAutomationEvent(id: Int(eventId),
                                                  event: eventEvent,
                                                  name: eventName,
                                                  metadata: metadata,
                                                  timestamp: timeStamp)
                    events.append(event)
                }
            }
            
            sqlite3_finalize(queryStatement)
            sqlite3_close(db)
            
            completion(events)
        }
    }
    
    // MARK: - Deletion

    static func deleteViews(_ views: [MBAutomationView],
                            completion: (() -> Void)? = nil) {
        guard views.count != 0 else {
            if let completion = completion {
                completion()
            }
            return
        }
        dbQueue.async {
            guard let db = openDatabase() else {
                return
            }
            
            let viewIds = views.compactMap({ String($0.id ?? 0) })
            let query = String(format: "DELETE FROM view WHERE id IN (%@)", viewIds.joined(separator: ","))
            
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_step(deleteStatement)
            }

            sqlite3_finalize(deleteStatement)

            sqlite3_close(db)
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    static func deleteEvents(_ events: [MBAutomationEvent],
                             completion: (() -> Void)? = nil) {
        guard events.count != 0 else {
            if let completion = completion {
                completion()
            }
            return
        }
        
        dbQueue.async {
            guard let db = openDatabase() else {
                return
            }
            
            let eventsIds = events.compactMap({ String($0.id ?? 0) })
            let query = String(format: "DELETE FROM event WHERE id IN (%@)", eventsIds.joined(separator: ","))
            
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_step(deleteStatement)
            }

            sqlite3_finalize(deleteStatement)
            sqlite3_close(db)
            
            if let completion = completion {
                completion()
            }
        }
    }

    // MARK: - DB Utilities
    
    private static func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        guard let dbPath = dbPath() else {
            return nil
        }
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            return db
        } else {
            return nil
        }
    }
    
    private static func dbPath() -> String? {
        let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("mb_automation_db.sqlite")
        return fileURL?.path
    }
    
    private static func stringForCString(_ cString: UnsafePointer<UInt8>) -> String? {
        return String(cString: cString)
    }
    
    static func jsonDictionaryForCString(_ cString: UnsafePointer<UInt8>) -> [String: Any]? {
        guard let string = stringForCString(cString) else {
            return nil
        }
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return nil
        }
        return object as? [String: Any]
    }
    
}
