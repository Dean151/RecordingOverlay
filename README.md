# RecordingOverlay

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ImageUtility.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/RecordingOverlay)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/Carthage/Carthage)

Adds a UIWindow containing a border layer of the color of your choise. Perfect to show an active state, or a recording state.

### Features

- iOS 9 & tvOS 9 compatible
- Add a border layer on the screen
- Adapts perfectly with the bezels of the device if any
- Animates in, out and "breathe"
- Supports any borders width & colors
- Allow to disable user interactions (and a whitelist of view still interactable)

### Requirements

- iOS ≥ 9 or tvOS ≥ 9
- Xcode ≥ 10.2
- Xcode ≥ 11 for Swift Package Manager integration

### Installation

#### Swift Package Manager

Only with Xcode 11+, add this repository to you project as a swift package.

#### Cocoapods

Specify in your Podfile:

```
target 'MyApp' do
pod 'RecordingOverlay'
end
```

#### Carthage

Specify in your Cartfile

```
github "Dean151/RecordingOverlay"
```

### Usage

You can instanciate a basic overlay with a static helper
```
// Show an overlay for 3s
let overlay = RecordingOverlay.show()
DispatchQueue.main.asyncAfter(deadline: .now + 3) {
    overlay.hide()
}
```

Or you may want to set things up a bit more:
```
// If you don't need to make your settings persistents after hiding,
// Store it in a weak variable. The overlay will retain itself while beeing shown.
weak var overlay: RecordingOverlay?

func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let overlay = RecordingOverlay()
    
    // Change the color
    overlay.color = .blue
    
    // And the border size
    overlay.length = 10
    
    // You may also want to disable the default "breathing" animation
    overlay.isAnimated = false
    
    // Then show it on the screen
    overlay.show(animated: animated)
    
    // It's shown, so it's autoretaining itself. The weak property will just be a reference.
    self.overlay = overlay
}

func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.overlay?.hide(animated: animated)
    // overlay is now nil since it's not retained anymore.
}
```

And you can also disable the user interactions completely, or partly:
```
// Disable user interactions, except for one view
overlay.disableInteractions(exceptFor: myViewInteractable)

// Or multiple views. When called multiple times, only the last list of views will be taken into account
overlay.disableInteractions(exceptFor: [view1, view2])

// Either you hide the the overlay to make the user returning the control, or you can enable back the interactions
overlay.enableInteractions()
```

### An issue?

Don't hesitate to fill an issue on Github, and/or contribute by forking and then propose changes via a Pull Request
