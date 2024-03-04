import Foundation

enum TunerEvent: String {
    case audioEngineStart = "Audio Engine Start",
         setAudioSessionCategory = "Set Audio Session Cateogry",
         audioEngineInterruption = "Audio Engine Interruption",
         audioEngineInterruptionUnknown = "Audio Engine Interruption Unknown",
         audioSessionSetActiveFailed = "Audio Session Set Active Failed",
         audioEngineInputNodeMissing = "Audio Engine Input Node Missing"
}
