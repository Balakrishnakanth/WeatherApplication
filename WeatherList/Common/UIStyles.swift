//
//  UIStyles.swift
//  WeatherApplicaiton
//
//  Created by KrishnaKanth B on 8/17/24.
//

import Foundation
import SwiftUI

/// UIStyle customizations

enum Colors {
    case primaryTextColor
    case whiteTextColor
    
    func colorView() -> Color {
        switch self {
        case .primaryTextColor:
            return .primary
        case .whiteTextColor:
            return .white
        }
    }
}

enum TextStyle {
    case h1
    case h2
    case small
    case medium
    case medium_bold
    case small_bold
}

extension View {
    /// Set the pre-defined text style
    ///  Make sure you call foregroundColor before style() to set custom forgroundColor
    @ViewBuilder func style(_ textStyle: TextStyle, viewColor: Color = .primary) -> some View {
        switch textStyle {
        case .h1:
            self.font(.system(size: 24, weight: .heavy))
                .foregroundColor(viewColor)
        case .h2:
            self.font(.system(size: 20, weight: .bold))
                .foregroundColor(viewColor)
        case .medium:
            self.font(.system(size: 16, weight: .regular))
                .foregroundColor(viewColor)
        case .medium_bold:
            self.font(.system(size: 16, weight: .bold))
                .foregroundColor(viewColor)
        case .small:
            self.font(.system(size: 14, weight: .regular))
                .foregroundColor(viewColor)
        case .small_bold:
            self.font(.system(size: 14, weight: .bold))
                .foregroundColor(viewColor)
                .lineSpacing(0.14)
        }
    }
}
