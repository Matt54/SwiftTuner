import XCTest
@testable import SwiftTuner

class TunerPitchTests: XCTestCase {
    func testFrequencyCalculation() {
        XCTAssertEqual(TunerPitch.a.noteFrequency, 440.0, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.aSharp.noteFrequency, 466.16, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.b.noteFrequency, 493.88, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.c.noteFrequency, 261.63, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.cSharp.noteFrequency, 277.18, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.d.noteFrequency, 293.66, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.dSharp.noteFrequency, 311.13, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.e.noteFrequency, 329.63, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.f.noteFrequency, 349.23, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.fSharp.noteFrequency, 369.99, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.g.noteFrequency, 392.00, accuracy: 0.01)
        XCTAssertEqual(TunerPitch.gSharp.noteFrequency, 415.30, accuracy: 0.01)
    }

    func testNoteNameSharp() {
        XCTAssertEqual(TunerPitch.a.noteNameSharp, "A")
        XCTAssertEqual(TunerPitch.aSharp.noteNameSharp, "A#")
        XCTAssertEqual(TunerPitch.b.noteNameSharp, "B")
        XCTAssertEqual(TunerPitch.c.noteNameSharp, "C")
        XCTAssertEqual(TunerPitch.cSharp.noteNameSharp, "C#")
        XCTAssertEqual(TunerPitch.d.noteNameSharp, "D")
        XCTAssertEqual(TunerPitch.dSharp.noteNameSharp, "D#")
        XCTAssertEqual(TunerPitch.e.noteNameSharp, "E")
        XCTAssertEqual(TunerPitch.f.noteNameSharp, "F")
        XCTAssertEqual(TunerPitch.fSharp.noteNameSharp, "F#")
        XCTAssertEqual(TunerPitch.g.noteNameSharp, "G")
        XCTAssertEqual(TunerPitch.gSharp.noteNameSharp, "G#")
    }

    func testAllCases() {
        XCTAssertEqual(TunerPitch.allCases, [.c, .cSharp, .d, .dSharp, .e, .f, .fSharp, .g, .gSharp, .a, .aSharp, .b])
    }
}
