import SwiftUI

public struct TunerRootView: View {
    @State var tuner: TunerConductor
    @State var isStartingUp: Bool = true
    @State var isSettingsShowing: Bool = false
    
    public init(tuner: TunerConductor = TunerConductor()) {
        self.tuner = tuner
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
        
        Group {
            if isSettingsShowing {
                TunerSettingsView(tuner: tuner)
            } else {
                TunerMainView(tuner: tuner, isStartingUp: isStartingUp)
            }
        }
        .ornament(attachmentAnchor: .scene(.topLeading), contentAlignment: .topTrailing) {
            VStack {
                Button("Mic", systemImage: isSettingsShowing ? "gearshape.fill" : "gearshape") {
                    isSettingsShowing.toggle()
                }
                .labelStyle(.iconOnly)
                
                Button("Mic", systemImage: !tuner.engineIsRunning ? "mic.fill" : "mic.slash") {
                    if tuner.engineIsRunning {
                        tuner.stop()
                    } else {
                        tuner.start()
                    }
                }
                .disabled(isStartingUp || isSettingsShowing)
                .labelStyle(.iconOnly)
            }
            .animation(.default, value: isSettingsShowing)
        }
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
}

#Preview("Root", windowStyle: .automatic,
         traits: .fixedLayout(width: 300, height: 300)) {
    TunerRootView(tuner: TunerConductor(isMockingInput: true))
}

// I don't want to show an error to the user if they happen to have an issue with the engine auto-starting on launch. They will just need to tap the mic manually to begin in that hopefully rare situation. In my testing, I don't get the issue anymore due to the delayed start.
#if DEBUG
let DISPLAY_INITIAL_AUDIO_ENGINE_ERROR = true
#else
let DISPLAY_INITIAL_AUDIO_ENGINE_ERROR = false
#endif