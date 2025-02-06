# key-event-widget

## Overview
**key-event-widget** is a Linux program that listens for key presses and triggers shell scripts based on predefined handlers. It consists of two main components:

1. **keyservice**: A Python script that monitors for key events and executes corresponding shell scripts.
2. **webserver**: A minimal web application that allows users to manage shell script handlers via a browser. It also ensures that `keyservice` is running and will start it automatically if it's not already running.

## Features
- Listens for keyboard and media key presses.
- Executes custom shell scripts based on key events.
- Provides a web interface for managing key event handlers.
- Logs key events and executed scripts.

![web interface](https://github.com/Udo/key-event-widget/blob/main/img/screenshot1.png?raw=true)

## Beware!
- I made this for a home automation key pad. Since this checks and executes shell scripts on key press/release, running this program on a desktop computer is probably a bad idea. However, in that use case you can take this thing as an example and modify the file 'keyservice' to execute some Python code when events happen, which should be a lot more performant.
- The webserver **is unsecured and unauthenticated**—users should take steps to restrict access or opt to run `keyservice` standalone.

## Installation
### Prerequisites
- Python 3
- `evdev` (for key event handling)
- `aiohttp` (for web server functionality)
- `jinja2` (for web template rendering)

### Setting Up
1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/key-event-widget.git
   cd key-event-widget
   ```
2. Run the setup script:
   ```sh
   ./setup.sh
   ```
   This script will initialize a virtual environment, install dependencies, and create necessary directories.

## Usage
### Running keyservice
Start the key event listener manually:
```sh
./keyservice
```
This script will detect key presses and execute shell scripts stored in the `handlers/` directory.

### Running webserver
Start the web interface:
```sh
./webserver
```
The webserver runs on port `80` by default and allows you to manage key event handlers. **It will automatically start `keyservice` if it's not already running.**

You can modify the port by changing the PORT variable in the webserver script.

Access it via a web browser at:
```
http://localhost/
```

### Running on System Startup
#### Using systemd
To start `keyservice` on boot, you can create a systemd service:
1. Create a new service file:
   ```sh
   sudo nano /etc/systemd/system/keyservice.service
   ```
2. Add the following content:
   ```ini
   [Unit]
   Description=Key Event Widget Service
   After=network.target

   [Service]
   ExecStart=/path/to/key-event-widget/keyservice
   Restart=always
   User=root
   Group=root
   WorkingDirectory=/path/to/key-event-widget

   [Install]
   WantedBy=multi-user.target
   ```
3. Reload systemd and enable the service:
   ```sh
   sudo systemctl daemon-reload
   sudo systemctl enable keyservice
   sudo systemctl start keyservice
   ```

#### Using crontab
Alternatively, you can start the `webserver` using `/etc/crontab`. Add the following line to `/etc/crontab` to ensure it starts on boot:
```sh
@reboot root /path/to/key-event-widget/webserver >> /path/to/key-event-widget/log/webserver.log 2>&1
```
This ensures that the webserver starts automatically upon reboot.

If using the webserver, ensure it's secured before exposing it publicly.

## Key Handlers
Each key event can trigger a shell script based on a naming scheme:
- `key-<device>-<key_code>-<event_type>`
- `key-<device>-<event_type>`
- `key-<key_code>-<event_type>`
- `key-<event_type>`
More information about this in the next section.

Example script handler:
```sh
#!/bin/bash
echo "Key $1 pressed on $2 ($3)" >> log/events.log
```

Example handler for OBS scene switching via the OBS WebSocket API:
```sh
#!/bin/bash
SCENE_NAME="MyScene"
curl -X POST "http://localhost:4455/obs-api" \
     -H "Content-Type: application/json" \
     -d '{"request-type": "SetCurrentProgramScene", "scene-name": "'$SCENE_NAME'"}'
```

Place the script in `handlers/`, make it executable:
```sh
chmod +x handlers/key-<your-key-handler>
```

## Key Handler Details

The script will stop calling event handlers after it found the first matching one. If you want it to instead try and call every possible matching handler, set the MATCH variable in the keyservice script to "all".

For example, let's say you press key number 96 on a numpad called 'SEM USB Keyboard'. keyservice will try the following handler scripts and invoke the first one of these it can actually find:

- 'key-usb-1c1b400-usb-1-input0-96-down'
- 'key-usb-1c1b400-usb-1-input0-down'
- 'key-SEM USB Keyboard-96-down'
- 'key-SEM USB Keyboard-down'
- 'key-96-down'
- 'key-down'

The script handlers start with a very specific name matching the USB port, model and the key exactly. Then it tries further handlers with less and less specific names until we're finally at 'key-down' which triggers for all key presses.

## Logs
- `/var/log/key.log` - Logs key presses and script executions.
- `/var/log/webserver.log` - Logs webserver activity.

## Security Warning
The webserver **is completely unsecured and lacks authentication**. Users should:
- Restrict access via firewall rules (e.g., `iptables` or `ufw`).
- Use a reverse proxy with authentication (e.g., `nginx` with basic auth).
- Run `keyservice` standalone if security is a concern.

## License
MIT License

## Contributing
Feel free to submit issues or pull requests to improve the project.

