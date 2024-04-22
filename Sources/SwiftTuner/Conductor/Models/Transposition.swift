//
//  Transposition.swift
//
//
//  Created by Matt Pfeiffer on 4/21/24.
//

import Foundation

public enum Transposition: Int, CaseIterable {
    case C = 0  // Concert pitch (no transposition)
    case Bb = 2  // Bb instruments transpose up 2 semitones (e.g., Bb clarinet, trumpet)
    case Eb = -3  // Eb instruments transpose down 3 semitones (e.g., alto saxophone)
    case F = -5  // F instruments transpose down 5 semitones (e.g., French horn)
    case D = 1  // D instruments transpose up 1 semitone (e.g., D trumpet)
    
    var displayName: String {
        switch self {
        case .C:
            return "C"
        case .Bb:
            return "B♭"
        case .Eb:
            return "E♭"
        case .F:
            return "F"
        case .D:
            return "D"
        }
    }
}
