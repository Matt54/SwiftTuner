import SwiftUI

struct TunerSettingsView: View {
    @Bindable var tuner: TunerConductor
    var openMainMenuAction: (()->Void)? = nil
    
    @State private var showingBufferSizeInfo: Bool = false
    @State private var showingAmplitudeThresholdInfo: Bool = false
    
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
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.title)
                .frame(maxWidth: .infinity)
            
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
            .padding(.bottom, 10)
            
            Slider(value: sensitivityBinding, in: 0...1.0) { isEditing in
                if !isEditing {
                    UserDefaultsManager.setAmplitudeThreshold(tuner.amplitudeThreshold)
                }
            }
            
            Spacer()
            
            Button {
                openMainMenuAction?()
            } label: {
                HStack {
                    Image(systemName: "house")
                    Text("Open Main Menu")
                }
            }
            .disabled(openMainMenuAction == nil)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .padding()
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
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 300, height: 300)) {
    TunerSettingsView(tuner: TunerConductor())
}

extension String {
    static var bufferSizeInfo: String {
        "Decrease for faster updates. Increase for better accuracy."
    }
    
    static var amplitudeThresholdInfo: String {
        "Decrease to filter out ambient sound. Increase if it's dropping readings from your instrument."
    }
}
