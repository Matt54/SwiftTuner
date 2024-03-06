# SwiftTuner

This open source Swift Package aims to create a great Tuner experience on visionOS. It uses the AudioKit library to provide real-time tuning information for pitch and deviation.

## Features

- **Real-time Tuning:** SwiftTuner provides real-time tuning information for pitch and deviation.
- **Customizable Settings:** Users can customize settings such as buffer size and amplitude threshold.

## Installation

### Swift Package Manager (SPM)

You can use Swift Package Manager to install SwiftTuner in your project. Follow these steps:

1. In Xcode, select your project in the project navigator.
2. Select the "Swift Packages" tab.
3. Click the "+" button and select "Add Package Dependency..."
4. Enter the URL of the SwiftTuner repository: `https://github.com/Matt54/SwiftTuner.git`
5. Click "Next" and follow the prompts to complete the installation.

## Usage

1. Import SwiftTuner into your Swift file: `import SwiftTuner`
2. Create an instance of `TunerConductor`: `let tuner = TunerConductor()`
3. Start the tuner: `tuner.start()`
4. Use the tuning information provided by the `TunerConductor` instance to adjust your instrument.

## Tuner Example

```swift
import SwiftTuner

let tuner = TunerConductor()
tuner.start()
// Use tuner.data.pitch, tuner.data.noteName, tuner.data.octaveNumber, tuner.data.deviation as needed
```

## Tuner View Example

``` swift
import SwiftTuner
import SwiftUI

@main
struct SpatialTunerApp: App {
    var body: some Scene {
        WindowGroup {
            TunerRootView(tuner: TunerConductor())
        }
        .windowResizability(.contentSize)
    }
}
```

## Credits

SwiftTuner is developed and maintained by Matt Pfeiffer and owes much thanks to the AudioKit contributors.

## License

SwiftTuner is released under the MIT License. See LICENSE for details.

## Contributing

PRs are very welcome!
