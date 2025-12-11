#!/bin/bash

# Configuration
COMMAND_PATH="/usr/bin"
REPO_URL="https://raw.githubusercontent.com/meibraransari/docker-short-command/main/docker_short_command.sh"
SCRIPT_NAME="docker_short_command.sh"

# definitions of commands: Name|Description|Type(simple/func)|Content
# Type "simple" content is the command itself (arguments handled automatically if simple alias)
# Type "func" content is the function body
# Type "script" content is a full script body
declare -a COMMANDS=(
    "dpl|docker pull|simple|docker pull \"\$@\""
    "dis|docker images|simple|docker images"
    "drn|docker run|simple|docker run \"\$@\""
    "dps|docker ps -a|simple|docker ps -a"
    "dpe|docker ps exited containers|script|clear && docker ps -a -f \"status=exited\""
    "dhc|docker healthcheck|script|clear
echo \"Fetching container status...\"
echo \"TABLE OF CONTAINER HEALTH STATUS\"
echo \"-------------------------------------\"
docker ps --format \"table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}\" | while read -r line; do
    if [[ \$line == *\"Up\"* ]]; then
        container_id=\$(echo \$line | awk '{print \$1}')
        health=\$(docker inspect --format='{{.State.Health.Status}}' \$container_id 2>/dev/null || echo \"N/A\")
        echo -e \"\$line\t\$health\"
    else
        echo \"\$line\"
    fi
done"
    "dpp|list containers with ports only|script|clear && docker ps --format \"table {{.ID}}\t{{.Names}}\t{{.Ports}}\""
    "dpi|list containers without command column|script|clear && echo -e \"List of running containers\" && docker ps --format \"table {{.ID}}\t{{.RunningFor}}\t{{.Status}}\t{{.Image}}\t{{.Names}}\""
    "dpia|list containers with detailed format|script|clear && docker ps --format \"table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\""
    "dsp|docker stop|simple|docker stop \"\$@\""
    "dst|docker start|simple|docker start \"\$@\""
    "drt|docker restart|simple|docker restart \"\$@\""
    "dre|docker rename|simple|docker rename \"\$@\""
    "dec|docker exec -it /bin/bash|script|docker exec -it \"\$@\" /bin/bash"
    "decx|docker exec -it /bin/sh|script|docker exec -it \"\$@\" /bin/sh"
    "dls|logs -fn 20|simple|docker logs --tail 20 -f \"\$@\""
    "drm|docker rm -f|simple|docker rm -f \"\$@\""
    "dri|docker rmi -f|simple|docker rmi -f \"\$@\""
    "dit|docker inspect|simple|docker inspect \"\$@\""
    "ditj|docker inspect Json format|script|docker inspect --format \"{{json .Config}}\" \"\$1\""
    "dvl|docker volume ls|simple|docker volume ls"
    "dss|docker stats|simple|docker stats"
    "drs|remove exited containers only|script|docker rm \$(docker ps -q -f status=exited)"
    "dhy|docker history|simple|docker history \"\$@\""
    "ddi|remove dangling image|script|docker rmi \$(docker images --filter \"dangling=true\" -q --no-trunc)"
    "drntest|docker run test container|simple|docker run -itd --name=test \"\$@\" /bin/bash"
    "dup|docker compose up (profile support)|script|profile_args=()
for profile in \"\$@\"; do
    profile_args+=(\"--profile=\$profile\")
done
if docker compose version > /dev/null 2>&1; then
    docker compose \"\${profile_args[@]}\" up -d
elif docker-compose version > /dev/null 2>&1; then
    docker-compose \"\${profile_args[@]}\" up -d
else
    echo \"Error: Docker Compose not found!\"
    exit 1
fi"
    "ddown|docker compose down (profile support)|script|profile_args=()
for profile in \"\$@\"; do
    profile_args+=(\"--profile=\$profile\")
done
if docker compose version > /dev/null 2>&1; then
    docker compose \"\${profile_args[@]}\" down
elif docker-compose version > /dev/null 2>&1; then
    docker-compose \"\${profile_args[@]}\" down
else
    echo \"Error: Docker Compose not found!\"
    exit 1
fi"
)

usage() {
    echo "Usage: $0 {install|uninstall|update|help}"
    echo
    echo "Commands:"
    echo "  install    Install the shortcut commands to $COMMAND_PATH"
    echo "  uninstall  Remove the shortcut commands from $COMMAND_PATH"
    echo "  update     Update this script and reinstall commands"
    echo "  help       Show this help message"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root.${NC}"
        exit 1
    fi
}

generate_help_command() {
    local help_file="$COMMAND_PATH/dhp"
    echo "Generating help command 'dhp'..."
    
    cat << EOF > "$help_file"
#!/bin/bash
echo "Docker Short Commands:"
echo "----------------------"
EOF

    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name desc type content <<< "$cmd_entry"
        # Align output
        printf "echo \"%-10s = %s\"\n" "$name" "$desc" >> "$help_file"
    done

    chmod 755 "$help_file"
}

install_commands() {
    check_root
    echo -e "${BLUE}Installing commands to $COMMAND_PATH...${NC}"

    # Generate individual commands
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name desc type content <<< "$cmd_entry"
        local file_path="$COMMAND_PATH/$name"
        
        echo "Creating $name..."
        echo "#!/bin/bash" > "$file_path"
        
        if [[ "$type" == "simple" ]]; then
            echo "$content" >> "$file_path"
        elif [[ "$type" == "script" ]]; then
            echo "$content" >> "$file_path"
        fi
        
        chmod 755 "$file_path"
    done

    # Generate help command separately
    generate_help_command

    echo -e "${GREEN}Installation complete!${NC}"
}

uninstall_commands() {
    check_root
    echo -e "${BLUE}Uninstalling commands from $COMMAND_PATH...${NC}"

    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r name desc type content <<< "$cmd_entry"
        local file_path="$COMMAND_PATH/$name"
        if [[ -f "$file_path" ]]; then
            echo "Removing $name"
            rm "$file_path"
        fi
    done

    if [[ -f "$COMMAND_PATH/dhp" ]]; then
        echo "Removing dhp"
        rm "$COMMAND_PATH/dhp"
    fi

    echo -e "${GREEN}Uninstallation complete!${NC}"
}

update_script() {
    check_root
    echo -e "${BLUE}Updating script...${NC}"
    local temp_file="/tmp/$SCRIPT_NAME"
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REPO_URL" -o "$temp_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$temp_file" "$REPO_URL"
    else
        echo -e "${RED}Error: Neither curl nor wget found.${NC}"
        exit 1
    fi

    if [[ -s "$temp_file" ]]; then
        echo -e "${GREEN}Downloaded latest version. Running install...${NC}"
        bash "$temp_file" install
        rm "$temp_file"
    else
        echo -e "${RED}Error: Failed to download update.${NC}"
        exit 1
    fi
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Main Logic

show_menu() {
    clear
    echo -e "${CYAN}----------------------------${NC}"
    echo -e "${BLUE}Docker Short Command Manager${NC}"
    echo -e "${CYAN}----------------------------${NC}"
    echo -e "${YELLOW}1)${NC} Install"
    echo -e "${YELLOW}2)${NC} Uninstall"
    echo -e "${YELLOW}3)${NC} Update"
    echo -e "${YELLOW}4)${NC} Help"
    echo -e "${YELLOW}5)${NC} Exit"
    echo
    read -p "Select an option [1-5]: " option
    case $option in
        1) install_commands ;;
        2) uninstall_commands ;;
        3) update_script ;;
        4) usage ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; exit 1 ;;
    esac
}

case "$1" in
    install|--install)
        install_commands
        ;;
    uninstall|--uninstall)
        uninstall_commands
        ;;
    update|--update)
        update_script
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        if [[ -z "$1" ]]; then
            show_menu
        else
            echo -e "${RED}Unknown command: $1${NC}"
            usage
            exit 1
        fi
        ;;
esac
