//
//  Checker.swift
//  DatabaseFrontend
//
//  Created by matei9k on 22/04/2024.
//

import Foundation
import SwiftUI

enum PasswordStrength {
    case invalid
    case empty
    case tooShort
    case noCapitals
    case noSmall
    case noNumbers
    case noSpecialCharacters
    case good
}

enum UsernameCreationStatus {
    case empty
    case short
    case good
}

enum MailCreationStatus {
    case empty
    case noAt
    case noDot
    case good
}

func checkPassword(for password: String) -> PasswordStrength {
    let password = password.trimmingCharacters(in: .whitespacesAndNewlines)

    if password.isEmpty {
        return PasswordStrength.empty
    }

    if password.count < 12 {
        return PasswordStrength.tooShort
    }

    if !password.contains(try! Regex("[A-Z]+")) {
        return PasswordStrength.noCapitals
    }

    if !password.contains(try! Regex("[a-z]+")) {
        return PasswordStrength.noSmall
    }

    if !password.contains(try! Regex("[0-9]+")) {
        return PasswordStrength.noNumbers
    }

    if !password.contains(try! Regex(#"[.!@#$%^&*(){};'\:<>,./?]+"#)) {
        return PasswordStrength.noSpecialCharacters
    }

    return PasswordStrength.good
}


struct ShowPasswordButton: View {
    @State var showPassword: Bool

    init(showPassword: Bool) {
        self.showPassword = showPassword
    }

    var body: some View {
        Button(action: { showPassword.toggle() }) {
            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill").font(.system(size: 16, weight: .regular))
        }
    }
}


