//
//  DatabaseFrontendApp.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import SwiftUI
import SQLite

typealias SwiftUIView = SwiftUI.View

@main
struct Main: App {
    var connection: Connection
    init() {
        if !databaseExists() {
            createDatabaseFile()
        }
        let conn = openSQLDatabaseConnection(at: getDatabasePath())
        do {
            _ = try conn.scalar(userTable.exists)
        }
        catch {
            initializeSQLDatabase(conn)
        }
        self.connection = conn
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView(connection: connection)
        }
#if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
#endif


    }
}
