# Pomodorot - Godot Pomodoro Timer

A simple, customizable Pomodoro timer application built with Godot.

## Features

- Pomodoro technique timing with work sessions and breaks
- Customizable durations for work, short breaks, and long breaks
- Command line options for automation
- Desktop notifications
- Sound alerts
- Minimization to system tray
- Always-on-top option
- Auto-start timers

## Command Line Options

The application supports the following command line options:

- `--start-timer`: Automatically starts the work timer when the application launches
- `--silent`: Runs in silent mode (no sounds or notifications)

## Settings

### General Settings
- **Always On Top**: Keeps the application window above other windows
- **Auto-start Work Timer**: Automatically starts the work timer after a break ends
- **Auto-start Break Timer**: Automatically starts a break timer after work ends
- **Desktop Notifications**: Shows desktop notifications when timers end
- **Minimize to Tray**: Allows the application to be minimized to the system tray
- **Minimize to Tray on Close**: Minimizes to tray instead of closing when the close button is clicked

### Sound Settings
- **Sound Enabled**: Enables or disables all sounds
- **Tick Sound**: Enables or disables the ticking sound during timers

### Timer Settings
- **Work Duration**: The length of work sessions in minutes
- **Short Break**: The length of short breaks in minutes
- **Long Break**: The length of long breaks in minutes
- **Long Break After**: Number of work cycles before a long break

## Opening the project from Source

1. Clone this repository
2. Open it in Godot and thats it;

## License

GPL-3.0 [License](LICENSE.md)

## Credits

Heavily based on pomodorolm (but wanted another one due to command line options...)
