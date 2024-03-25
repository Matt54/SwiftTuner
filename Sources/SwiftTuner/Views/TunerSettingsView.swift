import SwiftUI

struct TunerSettingsView: View {
    @Bindable var tuner: TunerConductor
    var openMainMenuAction: (()->Void)? = nil
    
    @State private var showingBufferSizeInfo: Bool = false
    @State private var showingAmplitudeThresholdInfo: Bool = false

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
                Text("Amp. Threshold: \(tuner.amplitudeThreshold, specifier: "%0.3f")")
            }
            .padding(.bottom, 10)
            
            Slider(value: $tuner.amplitudeThreshold, in: 0.01...0.1) { isEditing in
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
        .alert("Amplitude Threshold (dB.)", isPresented: $showingAmplitudeThresholdInfo) {
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
        "The number of samples which will be analyzed for each update. This influences how often the pitch is read."
    }
    
    static var amplitudeThresholdInfo: String {
        "Minimum loudness for a reading to be considered. Every buffer with an amplitude below this value is ignored."
    }
}
