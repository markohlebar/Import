# Import ☝️
Xcode extension for adding imports from anywhere in the code

![usage.gif](/Resources/usage.gif)

### Why? 
Because sometimes you are on 300th line of code and scrolling up just to add an import is a waste of time. 
This was built to replace [Peckham](https://github.com/markohlebar/Peckham), as  decided to drop support for Xcode plugins in Xcode 8. 

### Installation Guide (Xcode 8 / OSX 10.11+)

- close Xcode
- (*OSX 10.11 only*) `sudo /usr/libexec/xpccachectl`
- download the [Import app](https://github.com/markohlebar/Import/releases/download/1.0.3/Import.app.zip)
- unzip and copy to Applications folder
- run (right click + open)
- (*optional*) click on **Install Key Bindings** to install `⌘ + ctrl + P` binding
- ` -> System Preferences... -> Extensions -> All -> Enable Import`
- open Xcode
- select a source file
- check if `Editor -> Import -> ☝️` is there 
- WIN

### Usage

Import uses Xcode's autocomplete, this works best when written inside a function / a method

- type: `import MODULE_NAME` (`#import "HEADER_NAME.h"` in Obj-C) as you normally would
- press `⌘ + ctrl + P` or alternatively `Editor -> Import -> ☝️`

### Supported languages
- Swift
- Objective-C
- C++
- C

### License

MIT, see LICENSE
