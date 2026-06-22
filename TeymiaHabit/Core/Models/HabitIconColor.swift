import SwiftUI

enum HabitIconColor: String, CaseIterable, Codable {

    case primary, red, orange, yellow, mint, green, blue, purple
    case pink, brown, gray, softLavender, sky, coral, bluePink, oceanBlue
    case antarctica, sweetMorning, lusciousLime, celestial, yellowOrange, cloudBurst, candy, colorPicker

    var baseColor: Color {
        switch self {
        case .primary: .appPrimary
        case .red: .appRed
        case .orange: .appOrange
        case .yellow: .appYellow
        case .mint: .appMint
        case .green: .appGreen
        case .blue: .appBlue
        case .purple: .appPurple
        case .softLavender: .appSoftLavender
        case .pink: .appPink
        case .sky: .appSky
        case .brown: .appBrown
        case .gray: .appGray
        case .coral: .appCoral
        case .bluePink: .appBluePink
        case .oceanBlue: .appOceanBlue
        case .antarctica: .appAntarctica
        case .sweetMorning: .appSweetMorning
        case .lusciousLime: .appLusciousLime
        case .celestial: .appCelestial
        case .yellowOrange: .appYellowOrange
        case .cloudBurst: .appCloudBurst
        case .candy: .appCandy
        case .colorPicker: .appColorPicker
        }
    }

    var ringPair: (dark: Color, light: Color) {
        switch self {
        case .primary: (.appPrimaryDark, .appPrimaryLight)
        case .red: (.appRedDark, .appRedLight)
        case .orange: (.appOrangeDark, .appOrangeLight)
        case .yellow: (.appYellowDark, .appYellowLight)
        case .mint: (.appMintDark, .appMintLight)
        case .green: (.appGreenDark, .appGreenLight)
        case .blue: (.appBlueDark, .appBlueLight)
        case .purple: (.appPurpleDark, .appPurpleLight)
        case .pink: (.appPinkDark, .appPinkLight)
        case .brown: (.appBrownDark, .appBrownLight)
        case .gray: (.appGrayDark, .appGrayLight)
        case .softLavender: (.appSoftLavenderDark, .appSoftLavenderLight)
        case .sky: (.appSkyDark, .appSkyLight)
        case .coral: (.appCoralDark, .appCoralLight)
        case .bluePink: (.appBluePinkDark, .appBluePinkLight)
        case .oceanBlue: (.appOceanBlueDark, .appOceanBlueLight)
        case .antarctica: (.appAntarcticaDark, .appAntarcticaLight)
        case .sweetMorning: (.appSweetMorningDark, .appSweetMorningLight)
        case .lusciousLime: (.appLusciousLimeDark, .appLusciousLimeLight)
        case .celestial: (.appCelestialDark, .appCelestialLight)
        case .yellowOrange: (.appYellowOrangeDark, .appYellowOrangeLight)
        case .cloudBurst: (.appCloudBurstDark, .appCloudBurstLight)
        case .candy: (.appCandyDark, .appCandyLight)
        case .colorPicker: (.appColorPickerDark, .appColorPickerLight)
        }
    }
}
