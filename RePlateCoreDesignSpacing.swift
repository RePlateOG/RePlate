//
//  Spacing.swift
//  RePlate
//
//  Design system spacing and layout constants
//

import SwiftUI

enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48
}

enum CornerRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

enum Shadow {
    static let small = (color: Color.black.opacity(0.08), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let medium = (color: Color.black.opacity(0.12), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    static let large = (color: Color.black.opacity(0.16), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
}

enum Layout {
    static let maxWidth: CGFloat = 430
    static let tabBarHeight: CGFloat = 80
    static let navigationBarHeight: CGFloat = 44
    static let fabSize: CGFloat = 56
}
