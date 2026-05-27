//
//  RPTextField.swift
//  RePlate
//
//  Reusable text field component
//

import SwiftUI

struct RPTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let autocapitalization: TextInputAutocapitalization
    let error: String?
    
    @FocusState private var isFocused: Bool
    @State private var showPassword = false
    
    init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        autocapitalization: TextInputAutocapitalization = .sentences,
        error: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.autocapitalization = autocapitalization
        self.error = error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.textTertiary)
                        .frame(width: 20)
                }
                
                Group {
                    if isSecure && !showPassword {
                        SecureField(placeholder, text: $text)
                            .focused($isFocused)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(autocapitalization)
                            .focused($isFocused)
                    }
                }
                .font(.bodyLarge)
                .foregroundColor(.textPrimary)
                
                if isSecure {
                    Button(action: {
                        showPassword.toggle()
                        HapticManager.shared.light()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        HapticManager.shared.light()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.secondaryBackground)
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            
            if let error = error {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.labelSmall)
                    Text(error)
                        .font(.labelSmall)
                }
                .foregroundColor(.error)
            }
        }
    }
    
    private var borderColor: Color {
        if error != nil {
            return .error
        } else if isFocused {
            return .primaryGradientStart
        } else {
            return .clear
        }
    }
}

// MARK: - Preview
struct RPTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.lg) {
            RPTextField(
                "Email",
                placeholder: "Enter your email",
                text: .constant(""),
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            
            RPTextField(
                "Password",
                placeholder: "Enter your password",
                text: .constant(""),
                icon: "lock.fill",
                isSecure: true
            )
            
            RPTextField(
                "Name",
                placeholder: "Enter your name",
                text: .constant("John Doe"),
                icon: "person.fill"
            )
            
            RPTextField(
                "Error Example",
                placeholder: "This has an error",
                text: .constant(""),
                error: "This field is required"
            )
        }
        .padding()
    }
}
