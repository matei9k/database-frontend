//
//  AccountView.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import SwiftUI
import SQLite

struct AccountView: SwiftUIView {
    let user: User
    let created: Bool

    let connection: Connection

    @State var showUserError = false

    init(connection: Connection, user: User, created: Bool) {
        self.connection = connection
        self.user = user
        self.created = created
    }

    var body: some SwiftUIView {
        VStack(alignment: .leading){
            HStack {
#if os(macOS)
                Text("View user").font(.title).bold()
#endif

                Spacer()

                if created {
                    Button("Save user") {
                        if userExists(connection, name: user.name) {
                            showUserError = true
                        }
                        else {
                            showUserError = false
                            createUser(connection, with: user)
                        }
                    }
#if os(macOS)
                    .controlSize(.large)
#else
                    .controlSize(.regular)
#endif

#if !os(macOS)
                    Spacer()
#endif

                }


            }

            if showUserError {
#if !os(macOS)
                Spacer().frame(height: 10)
                HStack {
                    Spacer()
                    Text("The user '\(self.user.name)' already exists in the database.").bold().foregroundStyle(.red)
                        .font(.caption)
                    Spacer()
                }
#else
                Spacer().frame(height: 10)
                Text("The user '\(self.user.name)' already exists in the database.").bold().foregroundStyle(.red)
#endif
            }

            Spacer()

#if os(macOS)
            VStack(alignment: .leading) {
                Text("UUID").font(.title2).bold()
                Text(self.user.id.uuidString
                ).font(.title3).italic().lineLimit(1)
                Spacer().frame(height: 15)
                Text("E-mail").font(.title2).bold()
                Text(self.user.mail).font(.title3).italic()
                Spacer().frame(height: 15)
                Text("Username").font(.title2).bold()
                Text(self.user.name).font(.title3).italic()
                Spacer().frame(height: 15)
                Text("Hash").font(.title2).bold()
                Text(self.user.hash).font(.title3).italic().lineLimit(1)
                Spacer().frame(height: 15)
                Text("Salt").font(.title2).bold()
                Text(self.user.salt).font(.title3).italic()
            }
#else
            VStack(alignment: .leading) {
                Text("UUID").font(.title3).bold()
                Text(self.user.id.uuidString
                ).italic().lineLimit(1)
                Spacer().frame(height: 15)
                Text("E-mail").font(.title3).bold()
                Text(self.user.mail).italic()
                Spacer().frame(height: 15)
                Text("Username").font(.title3).bold()
                Text(self.user.name).italic()
                Spacer().frame(height: 15)
                Text("Hash").font(.title3).bold()
                Text(self.user.hash).italic().lineLimit(1)
                Spacer().frame(height: 15)
                Text("Salt").font(.title3).bold()
                Text(self.user.salt).italic()
            }

#endif


            Spacer()
        }.padding()
            .buttonStyle(.bordered)
#if os(macOS)
            .frame(minWidth: 500, minHeight: 500)
#else
            .navigationTitle("View user")
#endif
    }
}

#Preview {
    AccountView(connection: openSQLDatabaseConnection(at: getDatabasePath()), user: User(mail: "test@abc.com", name: "test123", hash: "hash", salt: "salt"), created: true)
}
