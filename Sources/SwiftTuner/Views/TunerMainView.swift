import SwiftUI

public struct TunerMainView: View {
    public init(tuner: TunerConductor = TunerConductor(), isStartingUp: Bool = false) {
        self.tuner = tuner
        self.isStartingUp = isStartingUp
    }
    
    @State var tuner: TunerConductor
    let isStartingUp: Bool
    
    var isInTune: Bool {
        return abs(tuner.data.deviation) <= 5
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            DeviationLabelHeader(deviation: tuner.data.deviation)
                .padding()
            
            if tuner.engineIsRunning {
                Text("\(tuner.data.noteName)")
                    .font(Font.system(size: 72))
                    .bold()
                    .overlay (
                        HStack {
                            if let octave = tuner.data.octaveNumber {
                                Spacer()
                                Text("\(octave)")
                                    .font(.body)
                            }
                        }
                        .offset(x: 18, y: 24)
                    )
            } else {
                if isStartingUp {
                    ProgressView()
                } else {
                    Text("Tap Mic to start")
                }
            }
            
            TunerMetricsViewHeader(pitch: tuner.data.pitch,
                                   deviation: tuner.data.deviation)
            .padding()
            
            DeviationIndicator(deviation: tuner.data.deviation, bufferSize: tuner.bufferSize)
            
            InTuneIndicator(isInTune: isInTune)
        }
        .padding()
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
        let bufferSize: BufferSize
        
        var body: some View {
            ZStack {
                // background tracks
                DeviationIndicatorArc(deviation: 50.0, bufferSize: bufferSize).opacity(0.25)
                DeviationIndicatorArc(deviation: -50.0, bufferSize: bufferSize).opacity(0.25)
                
                // dynamic arc
                DeviationIndicatorArc(deviation: deviation, bufferSize: bufferSize)
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
                .animation(.easeInOut(duration: 0.1), value: isHighlighted)
        }
    }
    
    struct DeviationIndicatorArc: View {
        let deviation: Float
        let bufferSize: BufferSize
        
        var body: some View {
            ArcShape(deviation: Double(deviation))
            .stroke(
                LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green]),
                                   startPoint: UnitPoint(x: 0.5, y: 0.5),
                                   endPoint: UnitPoint(x: 1.0, y: 0.5)),
                    style: .init(lineWidth: 25, lineCap: .round)
            )
                        .frame(width: 200, height: 200)
                        .animation(.easeInOut(duration: bufferSize.animationDuration), value: deviation)
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

#Preview("Main", windowStyle: .automatic,
         traits: .fixedLayout(width: 300, height: 300)) {
    var conductor = TunerConductor(isMockingInput: true)
    conductor.start()
    return TunerMainView(tuner: conductor)
}
