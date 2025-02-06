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
The webserver runs on port `8080` by default and allows you to manage key event handlers. **It will automatically start `keyservice` if it's not already running.**

Access it via a web browser at:
```
http://localhost:8080
```

### Running on System Startup
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
   User=yourusername
   Group=yourgroup
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

If using the webserver, ensure it's secured before exposing it publicly.

## Key Handlers
Each key event can trigger a shell script based on a naming scheme:
- `key-<device>-<key_code>-<event_type>`
- `key-<device>-<event_type>`
- `key-<key_code>-<event_type>`
- `key-<event_type>`

Example script handler:
```sh
#!/bin/bash
echo "Key $1 pressed on $2 ($3)" >> log/events.log
```

Place the script in `handlers/`, make it executable:
```sh
chmod +x handlers/key-<your-key-handler>
```

## Web API
The webserver exposes endpoints for managing handlers:
- `GET /log` - Fetches the last 10 log entries.
- `GET /handlers` - Lists available handlers.
- `GET /handlers/content?filename=<file>` - Retrieves a handler's content.
- `POST /handlers/add` - Creates a new handler.
- `POST /handlers/edit` - Updates an existing handler.
- `POST /handlers/delete` - Deletes a handler.

## Logs
- `log/key.log` - Logs key presses and script executions.
- `log/webserver.log` - Logs webserver activity.

## Security Warning
The webserver **is completely unsecured and lacks authentication**. Users should:
- Restrict access via firewall rules (e.g., `iptables` or `ufw`).
- Use a reverse proxy with authentication (e.g., `nginx` with basic auth).
- Run `keyservice` standalone if security is a concern.

## License
MIT License

## Contributing
Feel free to submit issues or pull requests to improve the project.

