import AudioKit
import AudioKitEX
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

// MARK: Properties and Initializer
@Observable
public class TunerConductor {
    public var data = TunerData()
    public var amplitudeThreshold: Float = UserDefaultsManager.getAmplitudeThreshold()
    public var engineIsRunning: Bool = false
    public var errorMessage: String? = nil
    
    public var dynamicsRange: ClosedRange<Float> = 0.01...0.1

    public var bufferSize: BufferSize = UserDefaultsManager.getBufferSize()  {
        didSet { updateTrackerBufferSize(bufferSize) }
    }
    
    // set this to your logger / analytics capturing class
    public var Logger: LogsEvents.Type?

    private var engine: AudioEngine?
    private var wasRunningWhenAudioInterrupted: Bool = false
    private var tracker: PitchTap?
//    private var amplitudeTracker: AmplitudeTap?
    private var mockDataGenerator: MockTunerDataGenerator? // For SwiftUI Previews
    private let noteFrequencies = TunerPitch.allCases.map({ $0.noteFrequency })
    private let noteNames = TunerPitch.allCases.map({ $0.noteNameSharp })

    public init(isMockingInput: Bool = false, Logger: LogsEvents.Type? = nil) {
        self.Logger = Logger
        if !isMockingInput {
            setupAudioChain()
            configureAudioSession()
        } else {
            setupMockDataGenerator()
        }
    }
}

// MARK: Public Methods
public extension TunerConductor {
    func start(shouldSetErrorMessage: Bool = true) {
        if let mockDataGenerator {
            mockDataGenerator.startGenerating()
            engineIsRunning = true
        } else {
            do {
                try engine?.start()
                tracker?.start()
//                amplitudeTracker?.start()
                engineIsRunning = true
                Logger?.log(TunerEvent.audioEngineStarted.rawValue, additionalContext: nil)
            } catch {
                if shouldSetErrorMessage {
                    errorMessage = error.localizedDescription
                }
                engineIsRunning = false
                tracker?.stop()
                Logger?.log(TunerEvent.audioEngineStartError.rawValue, additionalContext: ["error": String(describing: error)])
            }
        }
    }
    
    func stop() {
        if let mockDataGenerator {
            mockDataGenerator.stopGenerating()
        } else {
            tracker?.stop()
            engine?.stop()
            Logger?.log(TunerEvent.audioEngineStopped.rawValue, additionalContext: nil)
        }
        engineIsRunning = false
        data = TunerData()
    }
}

// MARK: Private Methods
extension TunerConductor {
    private func setupAudioChain() {
        engine = AudioEngine()
        
        guard let input = engine?.input else {
            Logger?.log(TunerEvent.audioEngineInputNodeMissing.rawValue, additionalContext: nil)
            errorMessage = "Audio input not found"
            return
        }
        
        // change buffer size to increase or decrease refresh rate of tracker
        tracker = PitchTap(input, bufferSize: bufferSize.rawValue) { pitch, amp in
            self.updatePitch(pitch[0], amp[0])
        }
        
//        let mixer = Mixer(input)
        
//        amplitudeTracker = AmplitudeTap(mixer, bufferSize: bufferSize.rawValue, handler: { amp in
//            DispatchQueue.main.async {
//                self.data.amplitude = amp
//            }
//        })

        // gain of zero to prevent feedback
        let fader = Fader(input, gain: 0)
        
        engine?.output = fader
    }
    
    private func setupMockDataGenerator() {
        let mockDataGenerator = MockTunerDataGenerator()
        mockDataGenerator.onUpdate = updatePitch
        self.mockDataGenerator = mockDataGenerator
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord,
                                         mode: .measurement,
                                         options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            Logger?.log(TunerEvent.setAudioSessionCategoryError.rawValue, additionalContext: ["error": String(describing: error)])
            errorMessage = error.localizedDescription
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: audioSession)
    }
    
    private func updateTrackerBufferSize(_ bufferSize: BufferSize) {
        if let input = engine?.input, tracker != nil {
            tracker = PitchTap(input, bufferSize: bufferSize.rawValue) { pitch, amp in
                self.updatePitch(pitch[0], amp[0])
            }
            if engineIsRunning {
                tracker?.start()
            }
            Logger?.log(TunerEvent.bufferSizeUpdated.rawValue, additionalContext: ["buffer_size": bufferSize])
        }
        UserDefaultsManager.setBufferSize(bufferSize)
    }
    
    private func updatePitch(_ pitch: AUValue, _ amp: AUValue) {
        DispatchQueue.main.async {
            self.data.amplitude = amp
        }
        
        guard amp > amplitudeThreshold else { return }

        var frequency = pitch
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }

        var minDistance: Float = 10000.0
        var index = 0

        for possibleIndex in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
            if distance < minDistance {
                index = possibleIndex
                minDistance = distance
            }
        }
        
        var octave = Int(log2f(pitch / frequency))
        var targetFrequency = noteFrequencies[index] * pow(2.0, Double(octave))
        var deviation = 1200 * log2(pitch / Float(targetFrequency))

        // Check if the deviation is out of range and adjust the note, octave, and deviation accordingly
        if deviation > 50 {
            index = (index + 1) % noteFrequencies.count
            if index == 0 {
                octave += 1
            }
            targetFrequency = noteFrequencies[index] * pow(2.0, Double(Float(octave)))
            deviation = 1200 * log2(pitch / Float(targetFrequency))
        }

        DispatchQueue.main.async {
            self.data.pitch = pitch
            self.data.noteName = "\(self.noteNames[index])"
            self.data.octaveNumber = octave
            self.data.deviation = deviation
        }
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            Logger?.log(TunerEvent.audioEngineInterruptionUnknown.rawValue, additionalContext: nil)
            return
        }
        
        let stringKeyedUserInfo: [String: Any] = userInfo.reduce(into: [String: Any]()) { result, pair in
            if let key = pair.key as? String {
                result[key] = pair.value
            }
        }

        Logger?.log(TunerEvent.audioEngineInterruption.rawValue, additionalContext: stringKeyedUserInfo)
        
        guard let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            wasRunningWhenAudioInterrupted = engineIsRunning
            stop()
        } else if type == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                Logger?.log(TunerEvent.audioSessionSetActiveFailed.rawValue, additionalContext: ["error": String(describing: error)])
            }
            
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                if wasRunningWhenAudioInterrupted {
                    start()
                }
            }
        }
    }
}
































public protocol AudioChainWithInput: ObservableObject {
    var engine: AudioEngine { get }
    var engineIsRunning: Bool { get }
    var bufferSize: BufferSize { get set }
    var audioReadingCallbacks: [([Float], [Float]) -> Void] { get }
    var errorCallback: ((_ message: String) -> Void)? { get }
    func start(shouldSetErrorMessage: Bool)
    func stop()
}

@Observable
class AudioChain: AudioChainWithInput {
    var engine: AudioEngine
    public var engineIsRunning: Bool = false
    private var wasRunningWhenAudioInterrupted: Bool = false
    
    private var tracker: PitchTap?
    public var Logger: LogsEvents.Type?
    
    public var bufferSize: BufferSize = UserDefaultsManager.getBufferSize()  {
        didSet { updateTrackerBufferSize(bufferSize) }
    }
    
    var audioReadingCallbacks: [([Float], [Float]) -> Void] = []
    var errorCallback: ((_ message: String) -> Void)?
    
    init() {
        self.engine = AudioEngine()
    }
    
    func setupAudioChain() {
        engine = AudioEngine()
        
        guard let input = engine.input else {
            Logger?.log(TunerEvent.audioEngineInputNodeMissing.rawValue, additionalContext: nil)
            errorCallback?("Audio input not found")
            return
        }
        
        // change buffer size to increase or decrease refresh rate of tracker
        tracker = PitchTap(input, bufferSize: bufferSize.rawValue) { pitch, amp in
            for callback in self.audioReadingCallbacks {
                callback(pitch, amp)
            }
        }

        // gain of zero to prevent feedback
        let fader = Fader(input, gain: 0)
        
        engine.output = fader
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord,
                                         mode: .measurement,
                                         options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            Logger?.log(TunerEvent.setAudioSessionCategoryError.rawValue, additionalContext: ["error": String(describing: error)])
            errorCallback?(error.localizedDescription)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: audioSession)
    }
    
    func start(shouldSetErrorMessage: Bool = true) {
        do {
            try engine.start()
            tracker?.start()
            engineIsRunning = true
            Logger?.log(TunerEvent.audioEngineStarted.rawValue, additionalContext: nil)
        } catch {
            if shouldSetErrorMessage {
                errorCallback?(error.localizedDescription)
            }
            engineIsRunning = false
            tracker?.stop()
            Logger?.log(TunerEvent.audioEngineStartError.rawValue, additionalContext: ["error": String(describing: error)])
        }
    }
    
    func stop() {
        tracker?.stop()
        engine.stop()
        Logger?.log(TunerEvent.audioEngineStopped.rawValue, additionalContext: nil)
        engineIsRunning = false
    }
    
    private func updateTrackerBufferSize(_ bufferSize: BufferSize) {
        if let input = engine.input, tracker != nil {
            tracker = PitchTap(input, bufferSize: bufferSize.rawValue) { pitch, amp in
                for callback in self.audioReadingCallbacks {
                    callback(pitch, amp)
                }
            }
            if engineIsRunning {
                tracker?.start()
            }
            Logger?.log(TunerEvent.bufferSizeUpdated.rawValue, additionalContext: ["buffer_size": bufferSize])
        }
        UserDefaultsManager.setBufferSize(bufferSize)
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            Logger?.log(TunerEvent.audioEngineInterruptionUnknown.rawValue, additionalContext: nil)
            return
        }
        
        let stringKeyedUserInfo: [String: Any] = userInfo.reduce(into: [String: Any]()) { result, pair in
            if let key = pair.key as? String {
                result[key] = pair.value
            }
        }

        Logger?.log(TunerEvent.audioEngineInterruption.rawValue, additionalContext: stringKeyedUserInfo)
        
        guard let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            wasRunningWhenAudioInterrupted = engineIsRunning
            stop()
        } else if type == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                Logger?.log(TunerEvent.audioSessionSetActiveFailed.rawValue, additionalContext: ["error": String(describing: error)])
            }
            
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                if wasRunningWhenAudioInterrupted {
                    start()
                }
            }
        }
    }
}
