# varanus

Varanus is an OSX framework written in Swift responsible for managing both
global and local application hotkeys.

### varanus
The framework was named after the [Varanus](http://en.wikipedia.org/wiki/Monitor_lizard) genus which monitor lizards are
a part of, because, after all, the main function the framework exposes is to
'monitor' the key down events in the system.

### How to include the framework in a project?
1. Clone the Varanus repository
```
git clone https://github.com/gfjalar/varanus.git
```
2. Open the project in XCode and build it
3. In XCode, right click Varanus/Products/Varanus.framework and 'Show in Finder'
4. Drag & drop Varanus.framework in the project
5. Inside the project(General settings) add Varanus.framework to
'Embedded Binaries'

*I found [Haroon Baig's post](https://medium.com/@PyBaig/build-your-own-cocoa-touch-frameworks-in-swift-d4ea3d1f9ca3) very helpful when creating the framework*

### Usage

To import:
```swift
import Varanus
```

To create new monitor:
```swift
// Event lifetime equals 0.1 by default
// Event lifetime is the time that can pass between different keyDown events
//   for them to still be considered as simultaneous
var monitor = KeyMonitor(lifetime: 0.1)
```

To create a hotkey:
```swift
// Creates a hotkey for Shift + Cmd + 'a' + 's'
var hotkey = KeyCombination(
	modifiers: [.Shift, .Cmd],
	codes: [0, 1]
)
```

To create a handler:
```swift
// Handler which doesn't require the event
func handler() {
	println("Handler")
}

// Handler which reads from the event
// If hotkey comprises of multiple key codes, the event will be of the one
// registered as the last one
func readOnlyHandler(event: NSEvent!) {
	println(event.timestamp)
	println("Read Only Handler")
}

// Handler which modifies the event
func eventHandler(event: NSEvent!) -> NSEvent! {
	println("Event Handler")
	// eg. return a different event
	return NSEvent()
}
```

To bind hotkey to the handler:
```swift
monitor.bind(hotkey, to: handler)

// Will return false, because hotkey is already in use
monitor.bind(hotkey, to: readOnlyHandler)
monitor.bind(hotkey, to: eventHandler)
```

To start the monitor:
```swift
// To capture events when application is not active
monitor.startGlobal()

// To capture events when application is active
monitor.startLocal()
```

To stop the monitor:
```swift
monitor.stopGlobal()
monitor.stopLocal()
```

### Why doesn't the global monitor work?
After [Apple Documentation](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/EventOverview/MonitoringEvents/MonitoringEvents.html)

*A global event monitor looks for user-input events dispatched to applications
other than the one in which it is installed. The monitor cannot modify an event
or prevent its normal delivery. And it may only monitor key events if
accessibility is enabled or if the application is trusted for accessibility.*

To enable accessibility:

1. Go to Apple -> System Preferences -> Security & Privacy -> Privacy ->
Accessibility
2. Click the lock to make changes
3. Enable the app you created or XCode if still in development

### TODO
* removing events from the monitor
* optimized event list
