import Foundation

public enum BufferSize: UInt32, CaseIterable, Identifiable {
    case oneHundredAndTwentyEight = 128
    case twoHundredAndFiftySix = 256
    case fiveHundredAndTwelve = 512
    case oneThousandAndTwentyFour = 1024
    case twoThousandAndFortyEight = 2048
    case fourThousandAndNinetySix = 4096
    
    var animationDuration: Double {
        Double(rawValue) / 48_000
    }
    
    public var id: UInt32 { self.rawValue }
}
