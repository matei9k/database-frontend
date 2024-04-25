//
//  ContentView.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import SwiftUI
import SQLite

struct WelcomeView: SwiftUIView {
    var connection: Connection = openSQLDatabaseConnection(at: getDatabasePath())

    var body: some SwiftUIView {
        NavigationStack {
            VStack {
                Text("Database").font(.title).bold()

                Text("Project")

                Spacer().frame(height: 50)

                HStack {
                    NavigationLink(destination: CreateView(connection: connection), label: {
                        Text("Create user")
                    })
#if os(macOS)
                    .controlSize(.large)
#else
                    .controlSize(.regular)
#endif

                    NavigationLink(destination: LoginView(connection: connection), label: {
                        Text("Authenticate")
                    })
#if os(macOS)
                    .controlSize(.large)
#else
                    .controlSize(.regular)
#endif

                }

                Divider().frame(width: 175)

                NavigationLink(destination: AccountListView(connection: connection), label: {
                    Text("View users")
                })
#if os(macOS)
                .controlSize(.large)
#else
                .controlSize(.regular)
#endif
            }
            .padding()
            .buttonStyle(.bordered)
#if os(macOS)
            .presentedWindowStyle(HiddenTitleBarWindowStyle())
            .frame(minWidth: 400, minHeight: 400, idealHeight: 400)
#endif
        }
    }
}

#Preview {
    WelcomeView()
}
