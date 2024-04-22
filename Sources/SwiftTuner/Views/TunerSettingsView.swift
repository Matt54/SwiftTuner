import SwiftUI

struct TunerSettingsView: View {
    @Bindable var tuner: TunerConductor
    
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

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tuner Settings")
                .font(.title3)
                .frame(maxWidth: .infinity)
            
            HStack {
                Button {
                    showingTranspositionInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                
                Text("Transposition:")
                Picker("Transposition", selection: $tuner.transposition) {
                    ForEach(Transposition.allCases, id: \.self) { transposition in
                        Text("\(transposition.displayName)").tag(transposition)
                    }
                }
            }
            
            HStack {
                Button {
                    showingBufferSizeInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                
                Text("Buffer Size:")
                Picker("Buffer Size", selection: $tuner.bufferSize) {
                    ForEach(BufferSize.allCases, id: \.id) { bufferSize in
                        Text("\(bufferSize.rawValue)").tag(bufferSize)
                    }
                }
            }
            .padding(.bottom, 10)
            
            HStack {
                Button {
                    showingAmplitudeThresholdInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                Text("Mic. Sensitivity: \(sensitivityBinding.wrappedValue, specifier: "%0.2f")")
            }
            
            Slider(value: sensitivityBinding, in: 0...1.0) { isEditing in
                if !isEditing {
                    UserDefaultsManager.setAmplitudeThreshold(tuner.amplitudeThreshold)
                }
            }
        }
        .padding()
        .padding(.horizontal)
        .alert("Buffer Size (samples)", isPresented: $showingBufferSizeInfo) {
            Button("OK", action: {})
        } message: {
            Text(String.bufferSizeInfo)
        }
        .alert("Microphone Sensitivity", isPresented: $showingAmplitudeThresholdInfo) {
            Button("OK", action: {})
        } message: {
            Text(String.amplitudeThresholdInfo)
        }
        .alert("Transposing Instrument", isPresented: $showingTranspositionInfo) {
            Button("OK", action: {})
        } message: {
            Text(String.transpositionInfo)
        }
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
