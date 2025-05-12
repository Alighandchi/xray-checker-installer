
# Xray Checker Auto Deployment

A simple, powerful tool to monitor and check your Xray proxy servers. This tool visualizes your subscription stats, connection quality, and server availability with beautiful charts.



## Features

- Real-time monitoring of your Xray servers
- Beautiful visualization with modern charts
- Subscription URL support for all major Xray panel types
- Docker-based installation for easy deployment
- Prometheus metrics for advanced monitoring

## Prerequisites

- Linux server (Ubuntu/Debian recommended)
- Docker
- Docker Compose
- Active subscription URL from a supported panel

## Compatibility

Works with all major Xray panel subscriptions:

- ✅ Marzban
- ✅ Marzneshin
- ✅ X-UI
- ✅ Hiddify
- ✅ 3x-UI
- ✅ Any panel with valid URI subscription format

## Quick Installation

1. Download the installation script:
   ```
   curl -O https://raw.githubusercontent.com/NotepadVpn/xray-checker-installer/main/install.sh
   ```

2. Make it executable:
   ```
   chmod +x install.sh
   ```

3. Run the script:
   ```
   ./install.sh
   ```

4. Follow the on-screen prompts to complete installation

## Usage

After installation, access the web interface at:
```
http://your-server-ip:PORT
```

Where PORT is the port you specified during installation (default: 2112)

## Support

Need help? Have questions?

- Contact: [@NotepadVpn](https://t.me/NotepadVpn) on Telegram
- Issue reporting: Submit issues on our GitHub repository

---

Created with ❤️ by [@NotepadVpn](https://t.me/NotepadVpn) - Your reliable partner for VPN solutions

