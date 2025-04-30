//
//  Validator.swift
//  AnimeTracker
//

import Foundation

// Protocolo genérico para validadores
protocol Validator {
    associatedtype T
    func validate(_ value: T) -> ValidationResult
}

// Resultado de validación con posibles errores
struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    
    static var success: ValidationResult {
        return ValidationResult(isValid: true, errors: [])
    }
    
    static func failure(errors: [ValidationError]) -> ValidationResult {
        return ValidationResult(isValid: false, errors: errors)
    }
}

// Errores de validación tipados
enum ValidationError: Error {
    case empty(field: String)
    case invalidFormat(field: String, message: String)
    case tooShort(field: String, minLength: Int)
    case tooLong(field: String, maxLength: Int)
    case custom(message: String)
    
    var localizedDescription: String {
        switch self {
        case .empty(let field):
            return "El campo \(field) no puede estar vacío"
        case .invalidFormat(let field, let message):
            return "El formato de \(field) es inválido: \(message)"
        case .tooShort(let field, let minLength):
            return "El campo \(field) debe tener al menos \(minLength) caracteres"
        case .tooLong(let field, let maxLength):
            return "El campo \(field) no debe exceder \(maxLength) caracteres"
        case .custom(let message):
            return message
        }
    }
}