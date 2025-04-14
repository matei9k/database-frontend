//
//  DeleteView.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import SwiftUI
import SQLite

struct DeleteView: SwiftUIView {
    let connection: Connection

    @State var name = String()
    @State var password = String()

    @State var showNameError = true

    @State var foundUser = User(mail: String(), name: String(), hash: String(), salt: String())

    @State var accountInvalid = false
    @State var hasVerifiedOnce = false
    @State var deleteSuccessful = false

    var body: some SwiftUIView {
        VStack {
            VStack(alignment: .leading) {
#if os(macOS)
                Text("Delete user").font(.title).bold()
#endif

                Spacer().frame(height: 25)

                Text("Username").font(.title3)
                if showNameError {
                    Text("The TextField for the username is empty.").bold().foregroundStyle(.red)
#if !os(macOS)
                        .font(.caption)
#endif
                }


                TextField("Username", text: $name).onChange(of: name, {
                    if name.isEmpty {
                        showNameError = true
                    }
                    else {
                        showNameError = false
                    }
                }).textContentType(.username)
            }

            Spacer()

            if accountInvalid {
                Text("This user does not exist.").bold().foregroundStyle(.red)
#if !os(macOS)
                    .font(.caption)
#endif
            }

            if deleteSuccessful {
                Text("The user has been successfully deleted.").bold().foregroundStyle(.green)
#if !os(macOS)
                    .font(.caption)
#endif
            }

            Button("Verify") {
                if deleteSuccessful {
                    deleteSuccessful = false
                }

                hasVerifiedOnce = true

                if !userExists(connection, name: name) {
                    accountInvalid = true
                }
                else {
                    accountInvalid = false
                }
            }.disabled(name.isEmpty).controlSize(.small)

            Button("Delete user") {
                deleteUser(connection, name: name)
                deleteSuccessful = true
                name = String()
                hasVerifiedOnce = false
            }.disabled(accountInvalid || showNameError || !hasVerifiedOnce)
#if os(macOS)
                .controlSize(.large)
#else
                .controlSize(.regular)
#endif
        }.padding()
#if os(macOS)
            .frame(minWidth: 700, minHeight: 500)
#endif
            .textFieldStyle(.roundedBorder)
            .buttonStyle(.bordered)
            .ignoresSafeArea(.keyboard)
#if !os(macOS)
            .navigationTitle("Delete user")
#endif
    }
}

#Preview {
    DeleteView(connection: openSQLDatabaseConnection(at: getDatabasePath()))
}

