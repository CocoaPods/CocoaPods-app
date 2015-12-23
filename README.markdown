# CocoaPods.app

The _foremost_ goal of CocoaPods.app is to provide a full-featured and standalone installation of
CocoaPods, instead of requiring users to install CocoaPods through RubyGems or Homebrew. In addition
to easy installation, it also includes ease of updating.

It is able to expose this standalone installation in a command-line interface environment through
the `pod` command-line tool, which it will request to install on launch of the application or
through the ‘Install the Command-Line Tool…’ menu item under the application menu.

### GUI

For now it provides a very minimalistic UI that allows users to open and edit their Podfile and
perform commands equivalent to `pod install` and `pod update`.

In time it will undoubtedly evolve into a full-featured GUI application, but for now this is **not**
the _most_ important goal.

### Building for Development

If you want to hack on `CocoaPods.app`:

``` sh
git clone https://github.com/CocoaPods/CocoaPods-app.git --recursive
cd CocoaPods-app
rake app:prerequisites --quiet
open app/CocoaPods.xcworkspace
```

This will set up your environment with a compiled versions of: ruby, git, cocoapods (the gem), hg, openssl, etc into both `destroot` and `workbench`.

### Building for Release

A release build will require the OS X 10.8 SDK that comes with Xcode 5.1.1, which can be downloaded
[here](https://developer.apple.com/downloads).

The main tasks can be found with `rake -T`:

```
rake app:build               # Build release version of application
rake app:clean               # Clean
rake app:prerequisites       # Prepare all prerequisites for building the app
rake app:update_version      # Updates the Info.plist of the application to reflect the CocoaPods version
rake bundle:build            # Build complete dist bundle
rake bundle:clean:all        # Clean all artefacts, including downloads
rake bundle:clean:artefacts  # Clean build and destroot artefacts
rake bundle:submodules       # Ensure Submodules are downloaded
rake bundle:test             # Test bundle
rake bundle:verify_linkage   # Verifies that no binaries in the bundle link to incorrect dylibs
rake release                 # Create a clean release build for distribution
rake release:build           # Perform a full build of the bundle and app
rake release:cleanbuild      # Create a clean build
rake release:upload          # Upload release
```

If you’re working on the build system and want to debug intermediate steps, such as building Ruby,
Git, Subversion, Mercurial, or Bazaar, be sure to checkout _all_ the tasks with `rake -T -A`.

We have heard reports of issues with installing on custom ruby installations, we'd recommend using system ruby (`rvm use system` for example) during the installation process. Nothing will be installed into the system, it all goes into the `destroot` folder, but then you have the same environment we are using.

### Creating a release

1. Run `rake release`.
2. [Create a new ‘release’](https://github.com/CocoaPods/CocoaPods-app/releases/new) on GitHub, which should show app specific changelog notes followed by the CocoaPods release changelog notes.
3. Checkout the `gh-pages` branch: `git clone https://github.com/CocoaPods/CocoaPods-app.git --branch gh-pages --single-branch gh-pages`.
4. Add `gh-pages/releases/VERSION.html` and recreate the changelog you added to the GitHub release as HTML.
5. Update `gh-pages/sparkle.xml` to include the new version ‘item’.
6. Make a pull request to [https://github.com/caskroom/homebrew-cask/blob/master/Casks/cocoapods.rb](homebrew-cask) updating the `version` and `sha256`
