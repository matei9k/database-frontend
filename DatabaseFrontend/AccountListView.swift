//
//  AccountListView.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import SwiftUI
import SQLite

struct AccountListView: SwiftUIView {
    let connection: Connection

    var body: some SwiftUIView {
        VStack {
            let db = getDatabaseUsers(connection)


            HStack {
#if os(macOS)
                Text("View users").font(.title).bold()

                Spacer()
#endif

                NavigationLink(destination: ResetView(connection: connection), label: {
                    Text("Reset password")
                }).disabled(db.isEmpty)
#if os(macOS)
                    .controlSize(.large)
#else
                    .controlSize(.regular)
#endif
                NavigationLink(destination: DeleteView(connection: connection), label: {
                    Text("Delete user")
                }).disabled(db.isEmpty)
#if os(macOS)
                    .controlSize(.large)
#else
                    .controlSize(.regular)
#endif


            }



#if os(macOS)
            Spacer().frame(height: 25)
            let alignment = HorizontalAlignment.leading
#else
            Spacer().frame(height: 10)
            let alignment = HorizontalAlignment.center
#endif

            VStack(alignment: alignment) {
                Text("User count: \(userCount(connection))").font(.caption)


#if os(iOS)
                Table(db) {
                    TableColumn("Username", value: \.name)
                    TableColumn("E-mail", value: \.mail)
                    TableColumn("Hash (SHA-512)", value: \.hash)
                    TableColumn("Salt", value: \.salt)
                }
#else
                Table(db) {
                    TableColumn("UUID", value: \.id.uuidString)
#if os(macOS)
                        .width(min: 300)
#endif
                    TableColumn("Username", value: \.name)
#if os(macOS)
                        .width(min: 160)
#endif
                    TableColumn("E-mail", value: \.mail)
#if os(macOS)
                        .width(min: 160)
#endif
                    TableColumn("Hash (SHA-512)", value: \.hash)
#if os(macOS)
                        .width(min: 240, ideal: 420)
#endif
                    TableColumn("Salt", value: \.salt)
#if os(macOS)
                        .width(min: 140)
#endif
                }
#endif
            }


        }.padding()
            .textFieldStyle(.roundedBorder)
            .buttonStyle(.bordered)
            .ignoresSafeArea(.keyboard)
#if !os(macOS)
            .navigationTitle("View users")
#endif
#if os(macOS)
            .frame(minWidth: 700, minHeight: 500)
#endif
    }

}


#Preview {
    AccountListView(connection: openSQLDatabaseConnection(at: getDatabasePath()))
}
