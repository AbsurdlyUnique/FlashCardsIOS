# FlashCards iOS App

## Project Structure

```
FlashCards/
├── Assets/
│   ├── Colors/         # Color definitions and palettes
│   ├── Gradients/      # Gradient definitions
│   ├── Fonts/          # Custom fonts
│   ├── Images/         # Static images
│   ├── Svgs/          # Vector graphics
│   ├── Animations/     # Animation assets
│   ├── Icons/         # UI icons
│   ├── Backgrounds/    # Background patterns
│   ├── Patterns/       # UI patterns
│   └── Textures/       # Textures for UI elements
├── FlashCards.xcodeproj/  # Xcode project files
├── FlashCardsTests/     # Unit tests
└── FlashCardsUITests/   # UI tests
```

## Color Palette

The app uses a custom color palette with the following colors:

- **Floral White**: #fffcf2ff (hsla(46, 100%, 97%, 1))
- **Timberwolf**: #ccc5b9ff (hsla(38, 16%, 76%, 1))
- **Black Olive**: #403d39ff (hsla(34, 6%, 24%, 1))
- **Eerie Black**: #252422ff (hsla(40, 4%, 14%, 1))
- **Flame**: #eb5e28ff (hsla(17, 83%, 54%, 1))

## Usage

All colors are defined in `Assets/Colors/Colors.swift` and can be accessed through the `ColorPalette` struct. For example:

```swift
// Accessing colors
let backgroundColor = ColorPalette.floralWhite

// Using gradients
let gradient = LinearGradient(
    gradient: ColorPalette.gradientTop,
    startPoint: .top,
    endPoint: .bottom
)
```
