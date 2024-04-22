import Foundation

enum TunerEvent: String {
    case audioEngineStarted = "Audio Engine Started",
         audioEngineStopped = "Audio Engine Stopped",
         setAudioSessionCategoryError = "Set Audio Session Category Error",
         audioEngineInterruption = "Audio Engine Interruption",
         audioEngineInterruptionUnknown = "Audio Engine Interruption Unknown",
         audioSessionSetActiveFailed = "Audio Session Set Active Failed",
         audioEngineInputNodeMissing = "Audio Engine Input Node Missing",
         bufferSizeUpdated = "Buffer Size Updated",
         audioEngineStartError = "Audio Engine Error",
         transpositionUpdated = "Transposition Updated"
}
