import Foundation

public struct TunerData {
    var amplitude: Float = 0.0
    var pitch: Float = 0.0
    var noteName = "-"
    var octaveNumber: Int?
    var deviation: Float = 0.0 // Deviation from the target pitch in cents
    
    var decibels: Float {
        // Convert amplitude to decibels relative to 20 µPa
        let referenceAmplitude: Float = 0.00002 // 20 µPa
        return 20 * log10(amplitude / referenceAmplitude)
    }
}
