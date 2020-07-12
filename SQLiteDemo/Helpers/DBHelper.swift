//
//  DBHelper.swift
//  SQLiteDemo
//
//  Created by https://medium.com/@imbilalhassan/saving-data-in-sqlite-db-in-ios-using-swift-4-76b743d3ce0e
//

import Foundation
import SQLite3

class DBHelper {
    init() {
        db = openDatabase()
        createTable()
    }

    private let dbPath = "myDb.sqlite"
    private var db: OpaquePointer?
}

// MARK: - Public interface

extension DBHelper {

    func insert(id: Int, name: String, age: Int) {
        let people = read()
        for p in people {
            if p.id == id {
                return
            }
        }

        let sql = "INSERT INTO person (id, name, age) VALUES (?, ?, ?);"
        var statement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("INSERT statement could not be prepared.", errorMessage)
            return
        }

        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int(statement, 1, Int32(id))
        sqlite3_bind_text(statement, 2, name.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 3, Int32(age))

        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted row.")
        } else {
            print("Could not insert row.", errorMessage)
        }
    }

    func read() -> [Person] {
        let sql = "SELECT * FROM person;"
        var statement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("SELECT statement could not be prepared.", errorMessage)
            return []
        }

        defer { sqlite3_finalize(statement) }

        var people: [Person] = []

        var returnCode = sqlite3_step(statement)
        while returnCode == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let name = sqlite3_column_text(statement, 1).flatMap { String(cString: $0) } ?? ""
            let year = sqlite3_column_int(statement, 2)
            people.append(Person(id: Int(id), name: name, age: Int(year)))

            returnCode = sqlite3_step(statement)
        }

        if returnCode != SQLITE_DONE {
            print("Error retrieving data.", errorMessage)
        }

        return people
    }

    func deleteByID(id: Int) {
        let sql = "DELETE FROM person WHERE id = ?;"
        var statement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("DELETE statement could not be prepared")
            return
        }

        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int(statement, 1, Int32(id))
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully deleted row.")
        } else {
            print("Could not delete row.", errorMessage)
        }
    }
}

// MARK: - Private implementation methods

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

private extension DBHelper {
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)

        var db: OpaquePointer? = nil
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database", errorMessage)
            sqlite3_close(db)
            db = nil
            return nil
        }
        
        print("Successfully opened connection to database at \(dbPath)")
        return db
    }

    func createTable() {
        let sql = "CREATE TABLE IF NOT EXISTS person (id INTEGER PRIMARY KEY, name TEXT, age INTEGER);"
        var statement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("CREATE TABLE statement could not be prepared.", errorMessage)
            return
        }

        defer { sqlite3_finalize(statement) }

        if sqlite3_step(statement) == SQLITE_DONE {
            print("person table created.")
        } else {
            print("person table could not be created.", errorMessage)
        }

    }

    /// SQLite error message

    var errorMessage: String {
        return sqlite3_errmsg(db)
            .flatMap { String(cString: $0) } ?? "Unknown error"
    }
}
