//
//  AuthValidator.swift
//  AnimeTracker
//

import Foundation

// Modelo para credenciales
struct Credentials {
    let email: String
    let password: String
}

// Validador de credenciales
struct CredentialsValidator: Validator {
    func validate(_ credentials: Credentials) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validar email
        if credentials.email.isEmpty {
            errors.append(.empty(field: "email"))
        } else if !isValidEmail(credentials.email) {
            errors.append(.invalidFormat(field: "email", message: "Debe ser un email válido"))
        }
        
        // Validar contraseña
        if credentials.password.isEmpty {
            errors.append(.empty(field: "contraseña"))
        } else if credentials.password.count < 6 {
            errors.append(.tooShort(field: "contraseña", minLength: 6))
        }
        
        return errors.isEmpty ? .success : .failure(errors: errors)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Validador para registro de usuario
struct RegistrationValidator: Validator {
    func validate(_ registration: RegistrationData) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validar username
        if registration.username.isEmpty {
            errors.append(.empty(field: "nombre de usuario"))
        } else if registration.username.count < 3 {
            errors.append(.tooShort(field: "nombre de usuario", minLength: 3))
        }
        
        // Validar credenciales
        let credentialsValidator = CredentialsValidator()
        let credentialsResult = credentialsValidator.validate(
            Credentials(email: registration.email, password: registration.password)
        )
        
        if !credentialsResult.isValid {
            errors.append(contentsOf: credentialsResult.errors)
        }
        
        // Validar confirmación de contraseña
        if registration.password != registration.confirmPassword {
            errors.append(.custom(message: "Las contraseñas no coinciden"))
        }
        
        return errors.isEmpty ? .success : .failure(errors: errors)
    }
}

// Datos para registro
struct RegistrationData {
    let username: String
    let email: String
    let password: String
    let confirmPassword: String
}