import Foundation

enum TunerPitch: CaseIterable {
    case c, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b

    // Reference frequency for A4
    static var a4Frequency = 440.0

    // Distance of each note from A4 in semitones
    private var semitoneOffsetFromA4: Int {
        switch self {
        case .a: return 0
        case .aSharp: return 1
        case .b: return 2
        case .c: return -9
        case .cSharp: return -8
        case .d: return -7
        case .dSharp: return -6
        case .e: return -5
        case .f: return -4
        case .fSharp: return -3
        case .g: return -2
        case .gSharp: return -1
        }
    }

    // Frequency calculation based on the equal temperament formula
    var noteFrequency: Double {
        let exponent = Double(semitoneOffsetFromA4) / 12.0
        return TunerPitch.a4Frequency * pow(2.0, exponent)
    }

    var noteNameSharp: String {
        switch self {
        case .c: return "C"
        case .cSharp: return "C#"
        case .d: return "D"
        case .dSharp: return "D#"
        case .e: return "E"
        case .f: return "F"
        case .fSharp: return "F#"
        case .g: return "G"
        case .gSharp: return "G#"
        case .a: return "A"
        case .aSharp: return "A#"
        case .b: return "B"
        }
    }
}
