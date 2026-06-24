//
//  Validators.swift
//  RePlate
//
//  OWASP A03 Injection — sanitize and validate all inputs at the system boundary
//  (user-facing form fields) before they reach Supabase or Stripe.
//

import Foundation

// MARK: - Validation Error

enum InputValidationError: LocalizedError {
    case empty(field: String)
    case tooShort(field: String, min: Int)
    case tooLong(field: String, max: Int)
    case invalidFormat(field: String)
    case outOfRange(field: String, min: Double, max: Double)

    var errorDescription: String? {
        switch self {
        case .empty(let f):               return "\(f) is required."
        case .tooShort(let f, let n):     return "\(f) must be at least \(n) characters."
        case .tooLong(let f, let n):      return "\(f) cannot exceed \(n) characters."
        case .invalidFormat(let f):       return "\(f) format is not valid."
        case .outOfRange(let f, let lo, let hi):
            return "\(f) must be between \(String(format: "%.2f", lo)) and \(String(format: "%.2f", hi))."
        }
    }
}

// MARK: - Validators

enum Validators {

    // OWASP A03: strip null bytes and leading/trailing whitespace from any string
    static func sanitize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\0", with: "")
    }

    // MARK: Email
    // Validates basic RFC-5321 email structure. Supabase performs a deeper check server-side.
    static func email(_ value: String) throws -> String {
        let trimmed = sanitize(value)
        if trimmed.isEmpty { throw InputValidationError.empty(field: "Email") }
        // Simple pattern: local@domain.tld — rejects obvious garbage without over-validating
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        guard trimmed.range(of: pattern, options: .regularExpression) != nil else {
            throw InputValidationError.invalidFormat(field: "Email")
        }
        if trimmed.count > 254 { throw InputValidationError.tooLong(field: "Email", max: 254) }
        return trimmed
    }

    // MARK: Password
    static func password(_ value: String) throws -> String {
        if value.isEmpty { throw InputValidationError.empty(field: "Password") }
        if value.count < 8 { throw InputValidationError.tooShort(field: "Password", min: 8) }
        if value.count > 128 { throw InputValidationError.tooLong(field: "Password", max: 128) }
        return value
    }

    // MARK: Display name / restaurant name
    static func name(_ value: String, field: String = "Name", maxLen: Int = 100) throws -> String {
        let trimmed = sanitize(value)
        if trimmed.isEmpty { throw InputValidationError.empty(field: field) }
        if trimmed.count < 2 { throw InputValidationError.tooShort(field: field, min: 2) }
        if trimmed.count > maxLen { throw InputValidationError.tooLong(field: field, max: maxLen) }
        return trimmed
    }

    // MARK: Listing title
    static func listingTitle(_ value: String) throws -> String {
        let trimmed = sanitize(value)
        if trimmed.isEmpty { throw InputValidationError.empty(field: "Title") }
        if trimmed.count > 200 { throw InputValidationError.tooLong(field: "Title", max: 200) }
        return trimmed
    }

    // MARK: Price
    // Accepts a string like "12.99" or "12,99"; returns the Double value.
    @discardableResult
    static func price(_ value: String, field: String = "Price") throws -> Double {
        let cleaned = value.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(cleaned), amount.isFinite else {
            throw InputValidationError.invalidFormat(field: field)
        }
        if amount < 0.01 || amount > 9_999.99 {
            throw InputValidationError.outOfRange(field: field, min: 0.01, max: 9_999.99)
        }
        return amount
    }

    // MARK: UUID
    // Returns true if value is a well-formed UUID v4; used for orderId pre-flight check.
    static func isUUID(_ value: String) -> Bool {
        UUID(uuidString: value) != nil
    }
}
