# Import ☝️
Xcode extension for adding imports from anywhere in the code

![usage.gif](/Resources/usage.gif)

### Installation Guide (Xcode 8 / OSX 10.11+)

- close Xcode
- (*OSX 10.11 only*) `sudo /usr/libexec/xpccachectl`
- download the [Import app](https://github.com/markohlebar/Import/releases/download/1.0.1/Import.app.zip)
- unzip and copy to Applications folder
- run (right click + open)
- (*optional*) click on **Install Key Bindings** to install `⌘ + ctrl + P` binding
- open Xcode
- select a source file
- check if `Editor -> Import -> ☝️` is there 
- WIN

### Usage

Import uses Xcode's autocomplete, this works best when written inside a function / a method

- type: `import MODULE_NAME` (`#import "HEADER_NAME.h"` in Obj-C) as you normally would
- press `⌘ + ctrl + P` or alternatively `Editor -> Import -> ☝️`

### License

MIT, see LICENSE
