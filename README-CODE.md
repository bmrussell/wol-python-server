# Code and Architecture Overview

## What the application does

This project is a small Flask web application for sending Wake-on-LAN (WoL) magic
packets to configured devices. A user opens the web page, chooses a device or
enters a MAC address, supplies that device's secret, and submits the form. The
server validates and normalizes the MAC address, checks the configured secret,
and asks the `wakeonlan` library to send the packet.

The application is intentionally compact: request handling, configuration
access, MAC-address handling, and packet dispatch are all implemented in
`webinterface.py`. There is no database, separate API, or background worker.

## Request and data flow

```text
Browser
  ├─ GET / ───────────────> Flask renders templates/base.html
  │                           └─ devices.yml data is embedded as JSON
  │                               for the device selector
  └─ POST / (address, secret)
       └─ webinterface.py
            ├─ netaddr normalizes and validates the MAC address
            ├─ devices.yml supplies the matching device secret
            ├─ wakeonlan sends the magic packet on successful authentication
            └─ Flask flash messages report the result on the rendered page
```

## Main code elements

### `webinterface.py`

The application entry point creates the Flask app and defines the `/` route for
both `GET` and `POST` requests.

- `get_devices_safe()` prepares the device aliases and optional addresses that
  are passed to the browser. It deliberately omits device secrets.
- `convert_to_bare(address)` parses a MAC address with `netaddr.EUI` and
  normalizes it to the bare MAC representation used for matching and sending.
- `get_device(address)` selects a device whose configured address matches. If
  none matches, it selects the first device without an address as the fallback
  (the sample configuration uses this for the custom-address option).
- The `/` route reads `address` and `secret` from a submitted form. It sends a
  packet only when the selected device's configured secret matches; otherwise,
  it shows a flash message. Invalid MAC formats are also reported with a flash
  message.
- When run directly, the module loads `logging.yml` and starts Flask on
  `0.0.0.0:5080` with debug mode enabled.

Device configuration is loaded from `devices.yml` when the module is imported.
The application therefore expects to be started with the project directory as
its working directory.

### `devices.yml`

Defines the `devices` mapping. Each entry has an `alias` and a `secret`; an
optional `address` identifies a fixed device. Entries without an address are
eligible for the custom-address fallback. The sample file includes example
values and should be customized for a real deployment.

### `templates/base.html`

Provides the single-page form and displays Flask flash messages. It receives
the public device data from the route, builds the device selector in
JavaScript, and fills the address field when a device is selected. A device
without a fixed address leaves the field available for manual entry.

### `static/`

Contains the page's stylesheet and JavaScript assets. `base.html` loads
`styles.css` and `jquery.js`; the other bundled compatibility scripts are
static assets and are not directly referenced by this template.

### `logging.yml`

Defines console and file logging handlers. It is applied by the direct-run
startup block in `webinterface.py`; the configured file handler writes to
`app.log` in the current working directory.

### `requirements.txt`

Lists the Python dependencies, including Flask for the web application,
`netaddr` for MAC parsing and normalization, `wakeonlan` for packet dispatch,
and PyYAML for configuration loading.

## Running locally

Install the dependencies and start the application from the repository root:

```bash
python -m pip install -r requirements.txt
python webinterface.py
```

The web interface listens on port `5080`. Wake-on-LAN delivery also depends on
the host's network allowing the magic packet to reach the target device.

## Container

Build an image with Podman using an explicit registry-qualified image name:

```bash
podman build -t localhost/wol-python-server:latest .
```

On Linux, use the host network so the WoL broadcast can reach the host's LAN:

```bash
podman run --rm --network host --name wol-python-server \
  localhost/wol-python-server:latest
```

The app listens on port `8880` in the container and, with host networking, is
available on the host at port `8880`. Port publishing (for example
`-p 8880:8880`) is unnecessary and ignored with host networking. A bridged
container network may publish the web interface but generally will not carry
the broadcast packet out to the physical LAN. The container defaults the WoL
destination to the `10.10.2.255` broadcast address; override
`WOL_BROADCAST_IP` if the LAN uses a different subnet.

## Runtime and deployment notes

- The server binds to all network interfaces and enables Flask debug mode in
  the direct-run path by default; set `FLASK_DEBUG=0` to disable it. The
  container sets this automatically. Production deployment should use an
  appropriate WSGI server and deployment-specific settings.
- Device secrets are stored in `devices.yml`, and the Flask session secret is
  defined in `webinterface.py`. Replace the sample credentials and protect
  both configuration and application secrets when deploying.
- Configuration and log paths are relative to the process working directory.
