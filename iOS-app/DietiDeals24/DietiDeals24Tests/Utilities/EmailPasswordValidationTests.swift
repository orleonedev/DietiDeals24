//
//  EmailPasswordValidationTests.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/17/25.
//


import Testing
import Foundation
@testable import DietiDeals24

@Suite("Validator Tests")
struct ValidatorTests{
    
    static let validator = Validator()

    struct EmailPasswordValidation_BlackBox_Tests {

        //MARK: test valid email and password
        @Test func validEmailAndPassword() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "ValidPassword123!")
            #expect(errors.isEmpty)
        }

        //MARK: test empty email
        @Test func emptyEmail() {
            let errors = validator.validateEmailAndPassword(email: "", password: "ValidPassword123!")
            #expect(errors == [.emptyEmail])
        }

        //MARK: test invalid email
        @Test func invalidEmail() {
            let errors = validator.validateEmailAndPassword(email: "invalid-email", password: "ValidPassword123!")
            #expect(errors == [.invalidEmail])
        }

        @Test func invalidEmail_MissingAtSymbol()  {
            let errors = validator.validateEmailAndPassword(email: "testexample.com", password: "ValidPassword123!")
            #expect(errors == [.invalidEmail])
        }
        
        @Test func invalidEmail_MissingDomain() {
            let errors = validator.validateEmailAndPassword(email: "test@", password: "ValidPassword123!")
            #expect(errors == [.invalidEmail])
        }

        //MARK: test empty password
        @Test func emptyPassword() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "")
            #expect(errors == [.emptyPassword])
        }

        //MARK: test invalid password
          @Test func invalidPassword_TooShort() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "short")
            #expect(errors == [.invalidPassword])
        }

        @Test func invalidPassword_NoUppercase() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "password123!")
            #expect(errors == [.invalidPassword])
        }

        @Test func invalidPassword_NoLowercase() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "PASSWORD123!")
            #expect(errors == [.invalidPassword])
        }

        @Test func invalidPassword_NoNumber() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "Password!")
            #expect(errors == [.invalidPassword])
        }

        @Test func invalidPassword_NoSpecialChar() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "Password123")
            #expect(errors == [.invalidPassword])
        }
        //MARK: test all invalid
        @Test func emptyEmailAndEmptyPassword() {
            let errors = validator.validateEmailAndPassword(email: "", password: "")
            #expect(errors == [.emptyEmail, .emptyPassword])
        }

        @Test func invalidEmailAndInvalidPassword() {
            let errors = validator.validateEmailAndPassword(email: "invalid", password: "short")
            #expect(errors.count == 2)
            #expect(errors.contains(.invalidEmail))
            #expect(errors.contains(.invalidPassword))
        }
        
        //MARK: Test long password
        @Test func longPassword() {
            let longPassword = String(repeating: "a", count: 200) + "A1!" // Assicura che sia valida anche se lunga
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: longPassword)
            #expect(errors.isEmpty)
        }

        //MARK: test valid email with special characters
        @Test func validEmailWithSpecialChars() {
            let errors = validator.validateEmailAndPassword(email: "test.name+alias@example.co.uk", password: "ValidPassword123!")
            #expect(errors.isEmpty)
        }

        @Test func passwordWithSpecialChars() {
            let errors = validator.validateEmailAndPassword(email: "test@example.com", password: "P@$$wOrd1")
            #expect(errors.isEmpty)
        }

        //MARK: Test invalid cases, all together.
        @Test func invalidCases() {
            let testCases: [(email: String, pass: String, expected: [Validator.ValidationError])] = [
                ("", "", [.emptyEmail, .emptyPassword]),
                ("invalid", "short", [.invalidEmail, .invalidPassword]),
                ("test@", "Password123!", [.invalidEmail]),
                ("test@example.com", "short", [.invalidPassword]),
                ("test@example.com", "password123!", [.invalidPassword]), // No uppercase
                ("test@example.com", "PASSWORD123!", [.invalidPassword]), // No lowercase
                ("test@example.com", "Password!", [.invalidPassword]),  // No number
                ("test@example.com", "Password123", [.invalidPassword]),  // No special char
                ("testexample.com", "ValidPassword123!", [.invalidEmail]), // Invalid email format
            ]
            
            for (email, password, expectedErrors) in testCases {
                let errors = validator.validateEmailAndPassword(email: email, password: password)
                #expect(errors == expectedErrors, "Failed for email: \(email), password: \(password)")
            }
        }
    }
}
