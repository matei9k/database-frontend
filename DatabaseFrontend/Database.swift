//
//  Database.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import Foundation
import SQLite

let location = "database.sqlite3"

struct User: Identifiable {
    let id = UUID()
    let mail: String
    let name: String
    let hash: String
    let salt: String
}

let id = Expression<UUID>("id")
let mail = Expression<String>("email")
let name = Expression<String>("name")
let hash = Expression<String>("hash")
let salt = Expression<String>("salt")

let userTable = Table("users")

func initializeSQLDatabase(_ connection: Connection) {
    try! connection.run(userTable.create { db in
        db.column(id, primaryKey: true)
        db.column(mail)
        db.column(name, unique: true)
        db.column(hash)
        db.column(salt)
    })
}

func getDatabaseUsers(_ connection: Connection) -> [User] {
    var users: [User] = []

    for user in try! connection.prepare(userTable) {
        users.append(User(mail: user[mail], name: user[name], hash: user[hash], salt: user[salt]))
    }

    return users
}

func createUser(_ connection: Connection, with details: User) {
    try! connection.run(userTable.insert(id <- details.id, mail <- details.mail, name <- details.name, hash <- details.hash, salt <- details.salt))
}

func deleteUser(_ connection: Connection, name accountName: String) {
    let user = userTable.filter(name == accountName)
    try! connection.run(user.delete())
}

func changeUserPasswordGeneric(_ connection: Connection, name accountName: String, hash accountHash: String) {
    let user = userTable.filter(name == accountName)
    let users = getDatabaseUsers(connection)
    let oldHash = users.first(where: { $0.name == accountName })!.hash
    try! connection.run(user.update(hash <- hash.replace(oldHash, with: accountHash)))
}

func changeUserPassword(_ connection: Connection, name accountName: String, oldHash: String, newHash: String) {
    let user = userTable.filter(name == accountName)
    try! connection.run(user.update(hash <- hash.replace(oldHash, with: newHash)))
}

func userExists(_ connection: Connection, name accountName: String) -> Bool {
    let users = getDatabaseUsers(connection)

    if users.contains(where: { accountName == $0.name }) {
        return true
    }
    else {
        return false
    }
}

func userCount(_ connection: Connection) -> Int {
    return try! connection.scalar(userTable.count)
}


//func writeToDatabase(contents: String) {
//    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//        let fileURL = dir.appendingPathComponent(location)
//        try! contents.appendLineToURL(fileURL: fileURL)
//    }
//}

//func clearDatabase(contents: String) {
//    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//        let fileURL = dir.appendingPathComponent(location)
//        try! contents.write(to: fileURL, atomically: false, encoding: .utf8)
//    }
//}

//func writeUserToDatabase(user: User) {
//    writeToDatabase(contents: "\(user.mail) \(user.name) \(user.hash) \(user.salt)")
//}

func readDatabase() -> String {
    if let dir = FileManager.default.urls(for: .documentDirectory
                                          , in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(location)
        return try! String(contentsOf: fileURL, encoding: .utf8)
    }
    else {
        return String()
    }
}


//func readDatabaseUsers() -> [User] {
//    let lines = readDatabase().split(separator: try! Regex("\n"))
//    var users: [User] = []
//
//    for line in lines {
//        let words = line.split(separator: try! Regex(" "))
//        let user = User(mail: String(words[0]), name: String(words[1]), hash: String(words[2]), salt: String(words[3]))
//        users.append(user)
//    }
//
//    return users
//}

func databaseExists() -> Bool {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(location)
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            return true
        }
        else {
            return false
        }
    }
    else {
        return false
    }
}


func createDatabaseFile() {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(location)
        if !FileManager.default.fileExists(atPath: dir.path()) {
            try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
        }
        if !FileManager.default.fileExists(atPath: fileURL.path()) {
            FileManager.default.createFile(atPath: fileURL.path(), contents: nil)
        }
    }
}

func getDatabasePath() -> String {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(location)
        return fileURL.path()
    }
    return String()
}


func openSQLDatabaseConnection(at location: String) -> Connection {
    return try! Connection(location)
}

//func checkUserInDatabase(name: String) -> Bool {
//    let users = readDatabaseUsers()
//    if users.contains(where: {
//        return name == $0.name
//    }) {
//        return true
//    }
//    else {
//        return false
//    }
//}
