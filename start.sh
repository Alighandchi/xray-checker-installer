#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' 

# Variables
DOCKER_IMAGE="kutovoys/xray-checker"
DOCKER_COMPOSE_FILE="/opt/xray-checker/docker-compose.yml"
INSTALL_DIR="/opt/xray-checker"
SUBSCRIPTION_URL=""
WEB_PORT="2112"
ENABLE_AUTH=false
USERNAME=""
PASSWORD=""
DOCKER_COMPOSE_CMD=""

print_banner() {
    clear
    echo -e "${CYAN}╭───────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}             ${WHITE}Xray Checker Tool${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}╰───────────────────────────────────────────────────────╯${NC}"
    echo -e "${YELLOW}              Auto Deployment Script by @NotepadVpn${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[${NC}${YELLOW}*${NC}${BLUE}]${NC} $1"
}

print_success() {
    echo -e "${BLUE}[${NC}${GREEN}+${NC}${BLUE}]${NC} $1"
}

print_error() {
    echo -e "${BLUE}[${NC}${RED}!${NC}${BLUE}]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[${NC}${CYAN}i${NC}${BLUE}]${NC} $1"
}

check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Would you like to install it now? [y/n]"
        read -r install_docker
        if [[ "$install_docker" =~ ^[Yy]$ ]]; then
            print_status "Installing Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            if [ $? -ne 0 ]; then
                print_error "Failed to install Docker. Please install it manually."
                exit 1
            else
                print_success "Docker installed successfully!"
            fi
        else
            print_error "Docker is required for this script to function. Exiting."
            exit 1
        fi
    else
        print_success "Docker is installed!"
    fi
    
    # Check for docker compose and determine the correct command format
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose (standalone) is installed!"
        DOCKER_COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        print_success "Docker Compose (plugin) is installed!"
        DOCKER_COMPOSE_CMD="docker compose"
    else
        print_error "Docker Compose is not installed. Would you like to install it now? [y/n]"
        read -r install_compose
        if [[ "$install_compose" =~ ^[Yy]$ ]]; then
            print_status "Installing Docker Compose..."
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            if [ $? -ne 0 ]; then
                print_error "Failed to install Docker Compose. Please install it manually."
                exit 1
            else
                print_success "Docker Compose installed successfully!"
                DOCKER_COMPOSE_CMD="docker-compose"
            fi
        else
            print_error "Docker Compose is required for this script to function. Exiting."
            exit 1
        fi
    fi
}

get_install_info() {
    echo -e "${CYAN}╭───────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}             ${WHITE}Xray Checker Configuration${NC}               ${CYAN}│${NC}"
    echo -e "${CYAN}╰───────────────────────────────────────────────────────╯${NC}"
    
    echo ""
    print_info "Please enter your subscription URL (required):"
    read -r SUBSCRIPTION_URL
    
    while [[ -z "$SUBSCRIPTION_URL" ]]; do
        print_error "Subscription URL cannot be empty. Please enter a valid URL:"
        read -r SUBSCRIPTION_URL
    done
    
    echo ""
    print_info "Please enter the web interface port (default: 2112):"
    read -r port_input
    if [[ -n "$port_input" ]]; then
        # Validate port is a number and in valid range
        if [[ "$port_input" =~ ^[0-9]+$ ]] && [ "$port_input" -ge 1 ] && [ "$port_input" -le 65535 ]; then
            WEB_PORT=$port_input
        else
            print_error "Invalid port number. Using default port: 2112"
        fi
    fi
    
    echo ""
    print_info "Would you like to enable basic authentication? [y/n] (default: n):"
    read -r enable_auth_input
    if [[ "$enable_auth_input" =~ ^[Yy]$ ]]; then
        ENABLE_AUTH=true
        
        echo ""
        print_info "Please enter the username for authentication:"
        read -r USERNAME
        
        while [[ -z "$USERNAME" ]]; do
            print_error "Username cannot be empty. Please enter a valid username:"
            read -r USERNAME
        done
        
        echo ""
        print_info "Please enter the password for authentication:"
        read -r PASSWORD
        
        while [[ -z "$PASSWORD" ]]; do
            print_error "Password cannot be empty. Please enter a valid password:"
            read -r PASSWORD
        done
    fi
}

create_docker_compose() {
    mkdir -p "$INSTALL_DIR"
    
    cat > "$DOCKER_COMPOSE_FILE" << EOF
version: '3'

services:
  xray-checker:
    image: ${DOCKER_IMAGE}
    container_name: xray-checker
    restart: unless-stopped
    environment:
      - SUBSCRIPTION_URL=${SUBSCRIPTION_URL}
EOF

    if [ "$ENABLE_AUTH" = true ]; then
        cat >> "$DOCKER_COMPOSE_FILE" << EOF
      - BASIC_AUTH_USERNAME=${USERNAME}
      - BASIC_AUTH_PASSWORD=${PASSWORD}
EOF
    fi

    cat >> "$DOCKER_COMPOSE_FILE" << EOF
    ports:
      - "${WEB_PORT}:2112"
    volumes:
      - ${INSTALL_DIR}/data:/app/data
EOF
}

install_xray_checker() {
    print_banner
    check_dependencies
    get_install_info
    
    print_status "Creating installation directory and configuration..."
    create_docker_compose
    
    print_status "Starting Xray Checker..."
    cd "$INSTALL_DIR" || exit
    
    # Use the correct Docker Compose command based on detection
    ${DOCKER_COMPOSE_CMD} -f "$DOCKER_COMPOSE_FILE" up -d
    
    if [ $? -eq 0 ]; then
        print_success "Xray Checker has been successfully installed and started!"
        print_info "You can access the web interface at: http://localhost:${WEB_PORT}"
        print_info "Prometheus metrics are available at: http://localhost:${WEB_PORT}/metrics"
        print_info "Installation directory: ${INSTALL_DIR}"
        echo ""
        print_info "Powered by @NotepadVpn - For secure and reliable VPN services!"
    else
        print_error "Failed to start Xray Checker. Please check the logs using: ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE} logs"
    fi
}

uninstall_xray_checker() {
    print_banner
    # Make sure Docker Compose command is set
    check_dependencies
    
    print_status "Checking if Xray Checker is installed..."
    
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        print_error "Xray Checker doesn't seem to be installed or was installed manually."
        print_info "If it was installed manually, please remove it through Docker commands."
        exit 1
    fi
    
    print_info "Are you sure you want to uninstall Xray Checker? This will remove all configuration data. [y/n]"
    read -r confirm_uninstall
    
    if [[ ! "$confirm_uninstall" =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled."
        return
    fi
    
    print_status "Stopping and removing Xray Checker containers..."
    cd "$INSTALL_DIR" || exit
    
    # Check if DOCKER_COMPOSE_CMD is empty and try to set it again
    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        if command -v docker-compose &> /dev/null; then
            DOCKER_COMPOSE_CMD="docker-compose"
        elif docker compose version &> /dev/null; then
            DOCKER_COMPOSE_CMD="docker compose"
        else
            print_error "Docker Compose command not found. Trying direct removal..."
            docker rm -f xray-checker &>/dev/null
            print_status "Removing installation directory..."
            rm -rf "$INSTALL_DIR"
            print_success "Xray Checker has been manually uninstalled!"
            return
        fi
    fi
    
    # Now run the Docker Compose command
    $DOCKER_COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" down -v
    
    print_status "Removing installation directory..."
    rm -rf "$INSTALL_DIR"
    
    print_success "Xray Checker has been successfully uninstalled!"
    print_info "Thank you for using @NotepadVpn services!"
}

show_menu() {
    print_banner
    
    echo -e "${CYAN}╭───────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}                   ${WHITE}Main Menu${NC}                        ${CYAN}│${NC}"
    echo -e "${CYAN}├───────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}1.${NC} Install Xray Checker                               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${RED}2.${NC} Uninstall Xray Checker                             ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}3.${NC} Exit                                              ${CYAN}│${NC}"
    echo -e "${CYAN}╰───────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${BLUE}Powered by @NotepadVpn - Secure & Reliable VPN Solutions${NC}"
    echo ""
    
    read -rp "Enter your choice [1-3]: " choice
    
    case $choice in
        1) install_xray_checker ;;
        2) uninstall_xray_checker ;;
        3) 
            echo -e "${GREEN}Thank you for using Xray Checker automated script by @NotepadVpn!${NC}"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please try again."
            sleep 2
            show_menu
            ;;
    esac
}

# Main execution
show_menu
