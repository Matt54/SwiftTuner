import Foundation

class MockTunerDataGenerator {
    var timer: Timer?
    var currentPitch: Float = 440.0 // Starting pitch
    var pitchChangeTime = Date()
    var onUpdate: ((Float, Float) -> Void)?

    func startGenerating() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // Change pitch every second
            if Date().timeIntervalSince(self.pitchChangeTime) > 5 {
                self.currentPitch = Float.random(in: 200...600) // Random new pitch
                self.pitchChangeTime = Date()
            } else {
                // Add some jitter to simulate real playing
                self.currentPitch += Float.random(in: -1...1)
            }

            // Call the update closure with the simulated pitch and a constant amplitude
            let randomAmplitude = Float.random(in: 0.01...0.1)
            self.onUpdate?(self.currentPitch, randomAmplitude)
        }
    }

    func stopGenerating() {
        timer?.invalidate()
    }
}
