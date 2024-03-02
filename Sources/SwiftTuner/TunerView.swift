//
//  TunerView.swift
//  SpatialTuner
//
//  Created by Matt Pfeiffer on 2/27/24.
//

import SwiftUI

public struct TunerView: View {
    public init(tuner: TunerConductor = TunerConductor()) {
        self.tuner = tuner
    }
    
    @State var tuner: TunerConductor
    @State var showAlert: Bool = false
    
    var isInTune: Bool {
        return abs(tuner.data.deviation) <= 5
    }
    
    public var body: some View {
        let showErrorAlert = Binding<Bool>(
            get: { tuner.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    tuner.errorMessage = nil
                }
            }
        )
        
        ZStack(alignment: .center) {
            DeviationLabelHeader(deviation: tuner.data.deviation)
                .padding()
            
            if tuner.engineIsRunning {
                Text("\(tuner.data.noteName)")
                    .font(Font.system(size: 72))
                    .bold()
                    .overlay (
                        Group {
                            HStack {
                                Spacer()
                                if let octave = tuner.data.octaveNumber {
                                    Text("\(octave)")
                                        .font(.body)
                                }
                            }
                            .offset(x: 18, y: 24)
                        }
                    )
            } else {
                Text("Tap Mic to start")
            }
            
            TunerMetricsViewHeader(pitch: tuner.data.pitch,
                                   deviation: tuner.data.deviation)
                .padding()
            
            DeviationIndicator(deviation: tuner.data.deviation)
            
            InTuneIndicator(isInTune: isInTune)
        }
        .padding()
        .frame(minWidth: 300, maxWidth: 300, minHeight: 300, maxHeight: 300)
        .ornament(attachmentAnchor: .scene(.topLeading), contentAlignment: .topTrailing) {
            Button("Mic", systemImage: !tuner.engineIsRunning ? "mic.fill" : "mic.slash") {
                if tuner.engineIsRunning {
                    tuner.stop()
                } else {
                    tuner.start()
                }
            }
            .labelStyle(.iconOnly)
            .padding(.bottom)
        }
        .onAppear {
            tuner.start()
        }
        .onDisappear {
            tuner.stop()
        }
        .alert("Contact Developer?", isPresented: $showAlert) {
            Button("Open Email") {
                // TODO: open email
            }
            Button("Cancel", role: .cancel, action: {})
        }
        .alert("Error", isPresented: showErrorAlert) {
            Button("OK", action: {})
        } message: {
            Text(tuner.errorMessage ?? "Something went wrong")
        }
    }
    
    struct InTuneIndicator: View {
        let isInTune: Bool
        
        var body: some View {
            VStack {
                Circle()
                    .fill(isInTune ? .primary : .secondary)
                    .frame(width: isInTune ? 29 : 25,
                           height: isInTune ? 29 : 25)
                    .padding(.top, isInTune ? 20 : 22)
                    .animation(.easeInOut(duration: 0.1), value: isInTune)
                    
                Spacer()
            }
        }
    }
    
    struct DeviationLabelHeader: View {
        let deviation: Float
        
        var isInTune: Bool {
            return abs(deviation) <= 5
        }
        
        var isFlat: Bool {
            guard !isInTune else { return false }
            return deviation < 0
        }
        
        var isSharp: Bool {
            guard !isInTune else { return false }
            return deviation > 0
        }
        
        var body: some View {
            VStack {
                HStack {
                    DeviationLabel(label: "♭", isHighlighted: isFlat)
                    Spacer()
                    DeviationLabel(label: "♯", isHighlighted: isSharp)
                }
                
                Spacer()
            }
        }
    }
    
    struct TunerMetricsViewHeader: View {
        let pitch: Float
        let deviation: Float
        
        var body: some View {
            VStack {
                Spacer()
                ZStack {
                    HStack {
                        Text("\(pitch, specifier: "%0.1f") Hz.")
                            .font(.body)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("\(deviation, specifier: "%+0.1f") cents.")
                            .font(.body)
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
    }
    
    struct DeviationIndicator: View {
        let deviation: Float
        
        var body: some View {
            ZStack {
                // background tracks
                DeviationIndicatorArc(deviation: 50.0).opacity(0.25)
                DeviationIndicatorArc(deviation: -50.0).opacity(0.25)
                
                // dynamic arc
                DeviationIndicatorArc(deviation: deviation)
            }
        }
    }
    
    struct DeviationLabel: View {
        let label: String
        let isHighlighted: Bool
        
        var body: some View {
            Text(label)
                .foregroundStyle(isHighlighted ? .secondary : .tertiary)
                .font(Font.system(size: isHighlighted ? 32 : 28))
                .frame(width: 20, height: 40)
        }
    }
    
    struct DeviationIndicatorArc: View {
        let deviation: Float
        
        var body: some View {
            ArcShape(deviation: Double(deviation))
            .stroke(LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green]),
                                   startPoint: UnitPoint(x: 0.5, y: 0.5),
                                   endPoint: UnitPoint(x: 1.0, y: 0.5)),
                    style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .animation(.easeInOut(duration: 0.0213), value: deviation)
                        .rotationEffect(.degrees(-90))
                        
        }

        var endAngle: Double {
            return Double(130 * (deviation / 50.0))
        }
        
        struct ArcShape: Shape {
            var deviation: Double
            
            var animatableData: Double {
                get { deviation }
                set { deviation = newValue }
            }
            
            let startAngle: Angle = Angle(degrees: 0)
            var endAngle: Angle {
                Angle(degrees: 130 * (deviation / 50.0))
            }
            
            var clockwise: Bool {
                return deviation < 0
            }

            func path(in rect: CGRect) -> Path {
                Path { path in
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    let radius = min(rect.width, rect.height) / 2
                    path.addArc(center: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: clockwise)
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic,
         traits: .fixedLayout(width: 300, height: 300)) {
    TunerView(tuner: TunerConductor(isMockingInput: true))
}
