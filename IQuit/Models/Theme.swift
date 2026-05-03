import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case dark
    case light
    case custom

    var name: String {
        switch self {
        case .dark:   return "Dark"
        case .light:  return "Light"
        case .custom: return "Custom"
        }
    }
}

// The actual resolved colors — computed from theme + custom colors
struct ThemeColors {
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let dotClean: Color
    let dotFuture: Color
    let surface: Color
    let border: Color
    let colorScheme: ColorScheme

    static func resolve(theme: AppTheme, customBg: Color, customAccent: Color) -> ThemeColors {
        switch theme {
        case .dark:
            return ThemeColors(
                background:  Color(hex: "0D0D0D"),
                primary:     Color(hex: "FFFFFF"),
                secondary:   Color(hex: "666666"),
                accent:      Color(hex: "E8E0D0"),
                dotClean:    Color(hex: "E8E0D0"),
                dotFuture:   Color(hex: "1E1E1E"),
                surface:     Color(hex: "161616"),
                border:      Color(hex: "252525"),
                colorScheme: .dark
            )
        case .light:
            return ThemeColors(
                background:  Color(hex: "F5F0EB"),
                primary:     Color(hex: "1A1A1A"),
                secondary:   Color(hex: "888888"),
                accent:      Color(hex: "2A2A2A"),
                dotClean:    Color(hex: "2A2A2A"),
                dotFuture:   Color(hex: "E0D8D0"),
                surface:     Color(hex: "EDE8E0"),
                border:      Color(hex: "D5CEC4"),
                colorScheme: .light
            )
        case .custom:
            // Background = user chosen bg, accent = user chosen accent
            // Derive secondary and surface from bg lightness
            return ThemeColors(
                background:  customBg,
                primary:     customAccent,
                secondary:   customAccent.opacity(0.5),
                accent:      customAccent,
                dotClean:    customAccent,
                dotFuture:   customAccent.opacity(0.15),
                surface:     customAccent.opacity(0.08),
                border:      customAccent.opacity(0.25),
                colorScheme: .dark // always dark for custom since bg is user-picked
            )
        }
    }
}
