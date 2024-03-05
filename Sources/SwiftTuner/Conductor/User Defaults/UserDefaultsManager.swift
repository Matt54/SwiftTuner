//
//  UserDefaultsManager.swift
//  
//
//  Created by Matt Pfeiffer on 3/5/24.
//

import Foundation

class UserDefaultsManager {
    static let defaultAmplitudeThreshold: Float = 0.025
    
    enum UserDefaultKey: String {
        case bufferSize = "kBufferSize"
        case amplitudeThreshold = "kAmplitudeThreshold"
    }
    
    static func getBufferSize() -> BufferSize {
        let key = UserDefaultKey.bufferSize.rawValue
        if UserDefaults.standard.integer(forKey: key) == 0 {
            let bufferSize = BufferSize.defaultValue
            setBufferSize(bufferSize)
            return bufferSize
        } else {
            let value = UserDefaults.standard.integer(forKey: key)
            let bufferSize = BufferSize(rawValue: UInt32(value))
            return bufferSize ?? .defaultValue
        }
    }
    
    static func setBufferSize(_ value: BufferSize) {
        UserDefaults.standard.set(Int(value.rawValue), forKey: UserDefaultKey.bufferSize.rawValue)
    }
    
    static func getAmplitudeThreshold() -> Float {
        let key = UserDefaultKey.amplitudeThreshold.rawValue
        if UserDefaults.standard.float(forKey: key) == 0 {
            setAmplitudeThreshold(defaultAmplitudeThreshold)
            return defaultAmplitudeThreshold
        } else {
            return UserDefaults.standard.float(forKey: key)
        }
    }
    
    static func setAmplitudeThreshold(_ value: Float) {
        UserDefaults.standard.set(value, forKey: UserDefaultKey.amplitudeThreshold.rawValue)
    }
}
