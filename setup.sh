#!/bin/bash

# Set environment variables for the script
export REPO_URL="https://github.com/Wizarrrr/wizarr.git"

RANDOM_DIR="/tmp/wizarr-$(date +%s)"
mkdir "$RANDOM_DIR"

# Declare variables for quick color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

BANNER='██     ██ ██ ███████  █████  ██████  ██████      ███████ ███████ ████████ ██    ██ ██████  \n██     ██ ██    ███  ██   ██ ██   ██ ██   ██     ██      ██         ██    ██    ██ ██   ██ \n██  █  ██ ██   ███   ███████ ██████  ██████      ███████ █████      ██    ██    ██ ██████  \n██ ███ ██ ██  ███    ██   ██ ██   ██ ██   ██          ██ ██         ██    ██    ██ ██      \n ███ ███  ██ ███████ ██   ██ ██   ██ ██   ██     ███████ ███████    ██     ██████  ██      \n'

# Function to generate the banner
generate_banner() {
    echo -e "\n\n${BLUE}$BANNER${NC}"
}

# Print the banner
generate_banner

# Print the repository URL
echo -e "\nRepository URL: ${GREEN}$REPO_URL${NC}\n"

# Get an array of branches from the repository
get_branches() {
    git ls-remote --heads "$REPO_URL" | sed 's?.*refs/heads/??'
}

# Function to select a branch using arrow keys
select_branch() {
    local branches=($(get_branches))
    local options=("master" "${branches[@]}")
    
    local selected_index=0
    
    while true; do
        clear
        
        # Print the branch options
        for ((i = 0; i < ${#options[@]}; i++)); do
            if [ $i -eq $selected_index ]; then
                echo -e "=> \033[1;33m${options[i]}\033[0m" # Yellow color for selected item
            else
                echo "   ${options[i]}"
            fi
        done
        
        read -s -n 1 key
        
        case $key in
            'A')  # Up arrow
                ((selected_index > 0)) && ((selected_index--))
            ;;
            'B')  # Down arrow
                ((selected_index < ${#options[@]} - 1)) && ((selected_index++))
            ;;
            '')  # Enter key
                git checkout "${options[selected_index]}"
                break
            ;;
            *)
            ;;
        esac
    done
}


# Clone the repository
clone_repo() {
    echo -e "${YELLOW}Cloning the repository...${NC}"
    git clone "$REPO_URL"
    cd "$(basename "$REPO_URL" .git)"
}

# Build the Docker image
build_image() {
    echo "Building the Docker image..."
    docker compose -f $RANDOM_DIR/docker-compose.yml build
}

# Run the Docker image
run_image() {
    echo "Running the Docker image..."
    docker compose -f $RANDOM_DIR/docker-compose.yml up -d
}

# Install Docker Compose
install_docker() {
    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    sudo curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
}

# Ask the user if they want to install Docker and Docker Compose
ask_install_docker() {
    while true; do
        echo -e "${YELLOW}"
        read -rp "Do you want to install Docker and Docker Compose? [Y/n] " yn
        echo -e "${NC}"
        case $yn in
            [Yy]* ) install_docker; break;;
            [Nn]* ) exit;;
            * ) echo -e "${RED}Invalid option. Try again.${NC}";;
        esac
    done
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker and try again.${NC}"
    install_docker
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose and try again.${NC}"
    exit
fi

# Clone the repository
clone_repo

# Select a branch to build the Docker image
select_branch

# Build the Docker image
build_image

# Ask the user if they want to run the Docker image or not
while true; do
    echo -e "${YELLOW}"
    read -rp "Do you want to run the Docker image? [Y/n] " yn
    echo -e "${NC}"
    case $yn in
        [Yy]* ) run_image; break;;
        [Nn]* ) exit;;
        * ) echo -e "${RED}Invalid option. Try again.${NC}";;
    esac
done

# Get version from latest file
VERSION=$(cat latest)

# Delete the cloned repository from /tmp
echo -e "${YELLOW}Deleting the cloned repository from tmp...${NC}"
rm -rf "$RANDOM_DIR"

# Clear the terminal
clear

# Print the URL to access the application
generate_banner
echo -e "${GREEN}URL: http://localhost:5690${NC}"
echo -e "${GREEN}Version: $VERSION${NC}\n"