## v0.12.2

- hide tray options on linux (godot doesn't support yet, use rbtray)
- Update test-aur-upload.yml
- improve theme option names
- cleanup settings dialog
- autofmt spacing, handle LineEdit better, fix audio set buttons and other misc changes


## v0.12.1

- Update to 4.5 and improve tick sound


## v0.11.3

- temporary solution for invisible audio files on export
- fix settings nested under containers
- only save window size when not maximised
- Add an autosave setting


## v0.11.2

- Update export_releases.yml to add fetch depth by @ragebreaker


## v0.11.1

- Improve all themes somewhat by @mlm-games


## v0.11.0

- Add proper settings organisation, fix timer settings not applying, show asetting only if applicable for the current OS by @mlm-studios


## v0.10.3

 - Fix alt+f4 or closing prevention setting

## v0.10.2

 - (Windows) Fix app not closing unless closed from tray
 - Fix chocolatey packages

## v0.10.1

 - Fix android builds

## v0.10.0

 - Add new timer display options (show percentage option, hide seconds option)
 - Fix audio not playing before alert
 - Add blocking closure of app option
 - Add a new theme with a different font (inter)

## v0.9.0

 - Add theming support in settings

## v0.8.1

 - the --silent cmd option now minimizes the window instead of disabling notifications and sound 
 - The old silent behaivor can be called by --no-popups-and-sound 

## v0.8.0

 - Add content screen size scaling option
 - Automatically scales screen size for android properly
 - Android: Use potrait (sensor) mode
 - Desktop: Add other placeholder options and hide minimize to tray option (don't yet know how to do that for godot)

## v0.7.9

 - Fix tick tock sound (still sounds a little bit odd)
 - Give proper name for fdroid release

## v0.7.8

 - Change the license name final for flathub metainfo.xml

## v0.7.7

 - Show notification then grab focus (for fullscreen blocking not occuring in some devices without switching to app)
 - Fix wrong metainfo.xml license name

## v0.7.6

 - Fix the naming of the release files of arm64 and x86 and x86_64 apks

## v0.7.5

 - Delete the build files that were causing the problems all along

## v0.7.4

 - Another release to fix flathub problems

## v0.7.3

 - Add flathub screenshots and files

## v0.7.2

 - Initial release
