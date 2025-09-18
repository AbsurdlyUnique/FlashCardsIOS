import SwiftUI

struct ColorPalette {
    // Primary Colors
    static let floralWhite = Color(hex: "#fffcf2ff")
    static let timberwolf = Color(hex: "#ccc5b9ff")
    static let blackOlive = Color(hex: "#403d39ff")
    static let eerieBlack = Color(hex: "#252422ff")
    static let flame = Color(hex: "#eb5e28ff")
    
    // Gradients
    static let gradientTop = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientRight = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientBottom = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientLeft = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientTopRight = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientBottomRight = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientTopLeft = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientBottomLeft = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
    
    static let gradientRadial = Gradient(colors: [
        floralWhite,
        timberwolf,
        blackOlive,
        eerieBlack,
        flame
    ])
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanLocation = 1
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
        let g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
        let b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
        let a = Double(rgbValue & 0x000000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
