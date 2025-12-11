# Docker Short Commands

A comprehensive collection of shortcut commands to simplify your Docker workflow. This script installs short, easy-to-remember aliases and helper scripts into your system path.

## 📝 Prerequisites
- Linux/Unix Environment
- Docker installed and running
- `curl` or `wget` (for installation)
- Root/Sudo privileges (for installation)

## 🚀 Features
- **Simplified Commands**: Replace long Docker commands with 3-4 letter shortcuts.
- **Enhanced Output**: Custom formatting for `docker ps` and `docker inspect`.
- **Safety**: Scripts are installed with proper permissions (`755`).
- **Management**: Easy install, uninstall, and update mechanisms.
- **Self-Documenting**: Built-in `dhp` command to list all available shortcuts.

## 📦 Available Commands

| Command | Description | Equivalent Docker Command / Function |
|---------|-------------|--------------------------------------|
| `dpl` | Pull image | `docker pull` |
| `dis` | List images | `docker images` |
| `drn` | Run container | `docker run` |
| `dps` | List all containers | `docker ps -a` |
| `dpe` | List exited containers | `docker ps -a -f "status=exited"` |
| `dhc` | Healthcheck status | Custom script to show container health status |
| `dpp` | List ports | Show container ID, Names, and Ports |
| `dpi` | List running summary | Show ID, Time, Status, Image, Names |
| `dpia` | detailed list | Show Names, ID, Status, Ports, Image, Command, Time |
| `dsp` | Stop container | `docker stop` |
| `dst` | Start container | `docker start` |
| `drt` | Restart container | `docker restart` |
| `dre` | Rename container | `docker rename` |
| `dec` | Exec (bash) | `docker exec -it <container> /bin/bash` |
| `decx` | Exec (sh) | `docker exec -it <container> /bin/sh` |
| `dls` | Logs (tail) | `docker logs --tail 20 -f` |
| `drm` | Remove container | `docker rm -f` |
| `dri` | Remove image | `docker rmi -f` |
| `dit` | Inspect | `docker inspect` |
| `ditj` | Inspect (JSON) | `docker inspect --format "{{json .Config}}"` |
| `dvl` | List volumes | `docker volume ls` |
| `dss` | Stats | `docker stats` |
| `drs` | Remove stopped | Remove all exited containers |
| `dhy` | History | `docker history` |
| `ddi` | Remove dangling | Remove all dangling images |
| `drntest`| Run test container | `docker run -itd --name=test ...` |
| `dup` | Compose Up | `docker compose up -d` (supports profiles) |
| `ddown` | Compose Down | `docker compose down` (supports profiles) |
| `dhp` | **Help** | **Lists all installed commands** |

## 📥 Installation

You can install the commands directly using `curl` or `wget`.

**Using wget:**
```bash
sudo bash <(wget -qO- https://raw.githubusercontent.com/meibraransari/docker-short-command/main/docker_short_command.sh) install
```

**Using curl:**
```bash
sudo bash <(curl -s https://raw.githubusercontent.com/meibraransari/docker-short-command/main/docker_short_command.sh) install
```

*Note: Running the script without arguments will open an interactive menu where you can choose to Install, Uninstall, Help, or Update.*

*To install non-interactively (e.g., in scripts), pass the `install` argument:*
```bash
sudo bash <(curl -s https://raw.githubusercontent.com/meibraransari/docker-short-command/main/docker_short_command.sh) install
```

## 🔄 Update

To update your scripts to the latest version found in the repository:

```bash
sudo docker_short_command.sh update
```
*(Note: Since the script itself isn't installed to bin, you might need to re-run the curl/wget command or keep the script locally)*

If you have the script saved locally:
```bash
sudo ./docker_short_command.sh update
```

## 🗑️ Uninstall

To remove all shortcuts and cleanup your system:

```bash
sudo ./docker_short_command.sh uninstall
```

## 🛠️ Usage Examples

**Check Health of Containers:**
```bash
dhc
```

**Enter a container's shell:**
```bash
dec my-container-name
```

**View JSON configuration of a container:**
```bash
ditj my-container-name
```

**Start a specific profile in docker compose:**
```bash
dup my-profile
```
