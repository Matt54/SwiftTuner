//
//  SwiftUIView.swift
//  
//
//  Created by Matt Pfeiffer on 4/16/24.
//

import SwiftUI

public struct DynamicsView: View {
    @State var tuner: TunerConductor
    var openMainMenuAction: (()->Void)?
    
    @State var isStartingUp: Bool = true
    @State var isSettingsShowing: Bool = false
    
    public init(tuner: TunerConductor = TunerConductor(),
                openMainMenuAction: (()->Void)? = nil) {
        self.tuner = tuner
        self.openMainMenuAction = openMainMenuAction
    }
    
//    // For my sanity while developing with a SwiftUI Preview
//    private var duration: Double {
//        #if DEBUG
//        return 0.25
//        #else
//        return tuner.bufferSize.animationDuration
//        #endif
//    }
    
    public var body: some View {
        let showErrorAlert = Binding<Bool>(
            get: { tuner.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    tuner.errorMessage = nil
                }
            }
        )
        
        ZStack {
            
            Text("\(String(format: "%.0f", tuner.data.decibels))")
                .font(Font.system(size: 72))
                .frame(width: 110)
                .bold()
                .overlay (
                    HStack {
                        if let octave = tuner.data.octaveNumber {
                            Spacer()
                            Text("dB")
                                .font(.body)
                        }
                    }
                    .offset(x: 15, y: 20)
                )
//                .animation(.linear(duration: duration), value: tuner.data.decibels)
            
            VStack {
                Spacer()
                HorizontalAmplitudeBar(amplitude: tuner.data.amplitude,
                                       amplitudeRange: tuner.dynamicsRange,
                                       animationDuration: tuner.bufferSize.animationDuration)
//                .frame(height: 40)
                
                Text("Amplitude: \(String(format: "%.3f", tuner.data.amplitude))")
                    .onAppear {
                        tuner.start()
                    }
            }
        }
        .padding()
        .frame(minWidth: 300, maxWidth: 300, minHeight: 300, maxHeight: 300)
        .onAppear {
            // Hack to work around how the audio engine doesn't want to start immediately. Sometimes you just need a little time 😃
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(2_000))) {
                tuner.start(shouldSetErrorMessage: DISPLAY_INITIAL_AUDIO_ENGINE_ERROR)
                isStartingUp = false
            }
        }
        .onDisappear {
            tuner.stop()
        }
        .alert("Error", isPresented: showErrorAlert) {
            Button("OK", action: {})
        } message: {
            Text(tuner.errorMessage ?? "Something went wrong")
        }
    }
    
    struct HorizontalAmplitudeBar: View {
        let amplitude: Float
        let amplitudeRange: ClosedRange<Float>
        let animationDuration: Double
        
        // For my sanity while developing with a SwiftUI Preview
        private var duration: Double {
            #if DEBUG
            return 0.25
            #else
            return tuner.bufferSize.animationDuration
            #endif
        }
        
        var fillPercentage: Float {
            if amplitude < amplitudeRange.lowerBound {
                return 0
            } else if amplitude > amplitudeRange.upperBound {
                return 1
            } else {
                return (amplitude - amplitudeRange.lowerBound) / (amplitudeRange.upperBound - amplitudeRange.lowerBound)
            }
        }
        
        var body: some View {
            HStack {
                ForEach(0..<16) { index in
                    Circle()
                        .foregroundColor(index < Int(fillPercentage * 16) ? .green : .black)
                }
            }
//            .animation(.linear(duration: duration), value: fillPercentage)
            
//            GeometryReader { geo in
//                HStack(spacing: 0) {
//                    Rectangle()
//                        .fill(.green)
//                        .frame(width: geo.size.width * CGFloat(fillPercentage))
//                    Rectangle()
//                        .fill(.black)
//                }
//                .animation(.linear(duration: duration), value: fillPercentage)
//                .mask(
//                    HStack(spacing: 10) {
//                        ForEach(0..<16, id: \.self) { _ in
//                            Circle()
//                        }
//                    }
//                )
//            }
        }
    }
}

#Preview("Dynamics View", windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    DynamicsView(tuner: TunerConductor(isMockingInput: true))
}
