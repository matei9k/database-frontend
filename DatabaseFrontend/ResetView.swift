//
//  ResetView.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import SwiftUI
import SQLite

struct ResetView: SwiftUIView {
    let connection: Connection

    @State var name = String()
    @State var password = String()

    @State var showNameError = true
    @State var showRepeatPasswordError = true
    @State var hasVerifiedOnce = false

    @State var foundUser = User(mail: String(), name: String(), hash: String(), salt: String())

    @State var newHash = String()
    @State var oldHash = String()

    @State var repeatedPassword = String()
    @State var repeatingPasswordsEqual = true
    @State var passwordNotNew = false
    @State var resetSuccessful = false

    @State var showPassword = false
    @State var showPasswordRepeating = false

    @State var passwordState = PasswordStrength.empty

    @State var accountInvalid = false

    var body: some SwiftUIView {
        VStack {
            VStack(alignment: .leading) {
#if os(macOS)
                Text("Reset password").font(.title).bold()
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

                Text("New password").font(.title3)
                Text("- must contain at least 12 characters").font(.caption)
                Text("- must be different from the previous password").font(.caption)
                Text("- must contain alphanumeric characters").font(.caption)
                Text("- must contain special characters ($, !, @, etc)").font(.caption)

                switch passwordState {
                case .empty:
                    Text("The TextField for the new password is empty.").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .invalid:
                    Text("The password is invalid.").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .tooShort:
                    Text("The password is too short.").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .noCapitals:
                    Text("The password does not contain capital letters.").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .noSmall:
                    Text("The password does not contain short characters.").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .noNumbers:
                    Text("The password does not contain numbers.").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .noSpecialCharacters:
                    Text("The password does not contain special characters").foregroundStyle(.red).bold()
#if !os(macOS)
                        .font(.caption)
#endif
                case .good:
                    EmptyView()
                }

                if !showPassword {
                    SecureField("New password", text: $password).onChange(of: password, {
                        passwordState = checkPassword(for: password)
                    }).textContentType(.password)
                }
                else {
                    TextField("New password", text: $password).onChange(of: password, {
                        passwordState = checkPassword(for: password)
                    }).textContentType(.password)

                }

                HStack {
                    Spacer()

                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill").font(.system(size: 16, weight: .regular)).frame(width: 20, height: 20)
                    }
                }

                Text("Repeat the new password").font(.title3)

                if showRepeatPasswordError {
                    Text("The TextField for the new password is empty.").bold().foregroundStyle(.red)
#if !os(macOS)
                        .font(.caption)
#endif
                }

                if !showPasswordRepeating {
                    SecureField("Repeat the new password", text: $repeatedPassword).onChange(of: repeatedPassword, {
                        if repeatedPassword.isEmpty {
                            showRepeatPasswordError = true
                        }
                        else {
                            showRepeatPasswordError = false
                        }
                    }).textContentType(.newPassword)
                }
                else {
                    TextField("Repeat the new password", text: $repeatedPassword).onChange(of: repeatedPassword, {
                        if repeatedPassword.isEmpty {
                            showRepeatPasswordError = true
                        }
                        else {
                            showRepeatPasswordError = false
                        }
                    }).textContentType(.newPassword)

                }

                HStack {
                    Spacer()

                    Button(action: { showPasswordRepeating.toggle() }) {
                        Image(systemName: showPasswordRepeating ? "eye.slash.fill" : "eye.fill").font(.system(size: 16, weight: .regular)).frame(width: 20, height: 20)
                    }
                }
                Spacer()
            }

            if accountInvalid {
                Text("This user does not exist.").bold().foregroundStyle(.red)
#if !os(macOS)
                    .font(.caption)
#endif
            }

            if !repeatingPasswordsEqual && !password.isEmpty && !repeatedPassword.isEmpty {
                Text("The passwords are not identical.").bold().foregroundStyle(.red)
#if !os(macOS)
                    .font(.caption)
#endif
            }

            if passwordNotNew {
                Text("The new password cannot be the same as the old one.").bold().foregroundStyle(.red)
#if !os(macOS)
                    .font(.caption)
#endif
            }

            if resetSuccessful {
                Text("The password has been successfully reset.").bold().foregroundStyle(.green)
#if !os(macOS)
                    .font(.caption)
#endif
            }

            Button("Verify") {
                if resetSuccessful {
                    resetSuccessful = false
                }

                hasVerifiedOnce = true

                if password == repeatedPassword {
                    repeatingPasswordsEqual = true
                } else {
                    repeatingPasswordsEqual = false
                }

                passwordNotNew = false
                if !userExists(connection, name: name) {
                    accountInvalid = true
                }
                else {
                    accountInvalid = false

                    let d = getDatabaseUsers(connection)
                    foundUser =  d.first(where: { $0.name == name })!

                    oldHash = foundUser.hash
                    newHash = computeHash(for: password, salt: foundUser.salt)

                    if oldHash == newHash {
                        passwordNotNew = true
                    } else {
                        passwordNotNew = false
                    }

                }
            }.disabled(name.isEmpty || password.isEmpty || repeatedPassword.isEmpty).controlSize(.small)

            Button("Reset password") {
                changeUserPassword(connection, name: name, oldHash: oldHash, newHash: newHash)
                resetSuccessful = true
                name = String()
                password = String()
                repeatedPassword = String()
                hasVerifiedOnce = false
            }.disabled(accountInvalid || showNameError || passwordState != .good || !hasVerifiedOnce || !repeatingPasswordsEqual || passwordNotNew)
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
            .navigationTitle("Reset password")
#endif
    }
}

#Preview {
    ResetView(connection: openSQLDatabaseConnection(at: getDatabasePath()))
}

