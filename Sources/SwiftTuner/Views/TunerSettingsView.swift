import SwiftUI

public struct TunerSettingsView: View {
    @Bindable var tuner: TunerConductor
    
    public init(tuner: TunerConductor) {
        self.tuner = tuner
    }
    
    @State private var showingBufferSizeInfo: Bool = false
    @State private var showingAmplitudeThresholdInfo: Bool = false
    @State private var showingTranspositionInfo: Bool = false
    
    // user friendly value in 0-1 range (flips range so increasing provides more readings)
    private var sensitivityBinding: Binding<Float> {
        Binding(
            get: {
                // Map the amplitudeThreshold from 0.1...0.01 to 0...1
                (0.1 - tuner.amplitudeThreshold) / 0.09
            },
            set: {
                // Map the sensitivity from 1...0 back to 0.01...0.1
                tuner.amplitudeThreshold = 0.1 - $0 * 0.09
            }
        )
    }
    
    var infoCircle: some View {
        Image(systemName: "info.circle")
            .foregroundStyle(.secondary)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tuner Settings")
                .font(.title3)
                .frame(maxWidth: .infinity)
            
            HStack {
                Button {
                    showingTranspositionInfo = true
                } label: {
                    infoCircle
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .popover(
                    isPresented: $showingTranspositionInfo, arrowEdge: .bottom
                ) {
                    Text(String.transpositionInfo)
                        .frame(width: 300)
                        .padding()
                }
                
                Text("Transposition:")
                Spacer(minLength: 0)
                Picker("Transposition", selection: $tuner.transposition) {
                    ForEach(Transposition.allCases, id: \.self) { transposition in
                        Text("\(transposition.displayName)").tag(transposition)
                    }
                }
                .frame(width: 105)
            }
            
            HStack {
                Button {
                    showingBufferSizeInfo = true
                } label: {
                    infoCircle
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .popover(
                    isPresented: $showingBufferSizeInfo, arrowEdge: .bottom
                ) {
                    Text(String.bufferSizeInfo)
                        .frame(width: 300)
                        .padding()
                }
                
                Text("Buffer Size:")
                Spacer(minLength: 0)
                Picker("Buffer Size", selection: $tuner.bufferSize) {
                    ForEach(BufferSize.allCases, id: \.id) { bufferSize in
                        Text("\(bufferSize.rawValue)").tag(bufferSize)
                    }
                }
                .frame(width: 105)
            }
            .padding(.bottom, 10)
            
            ZStack(alignment: .topLeading) {
                Button {
                    showingAmplitudeThresholdInfo = true
                } label: {
                    infoCircle
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .popover(
                    isPresented: $showingAmplitudeThresholdInfo, arrowEdge: .bottom
                ) {
                    Text(String.amplitudeThresholdInfo)
                        .frame(width: 300)
                        .padding()
                }
                
                VStack(spacing: 18) {
                    Text("Mic. Sensitivity: \(sensitivityBinding.wrappedValue, specifier: "%0.2f")")
                    Slider(value: sensitivityBinding, in: 0...1.0) { isEditing in
                        if !isEditing {
                            UserDefaultsManager.setAmplitudeThreshold(tuner.amplitudeThreshold)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        .padding()
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    TunerSettingsView(tuner: TunerConductor())
}

extension String {
    static var transpositionInfo: String {
        "C for concert, B♭ for trumpet or clarinet, E♭ for alto saxophone, and so on. This adjusts the displayed notes to align with how you read music."
    }
    
    static var bufferSizeInfo: String {
        "Decrease for faster updates. Increase for better accuracy."
    }
    
    static var amplitudeThresholdInfo: String {
        "Decrease to filter out ambient sound. Increase if it's dropping readings from your instrument."
    }
}
