import Foundation

public struct TunerData {
    var pitch: Float = 0.0
    var noteName = "-"
    var octaveNumber: Int?
    var deviation: Float = 0.0 // Deviation from the target pitch in cents
}
