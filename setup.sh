#!/bin/bash

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y
sudo apt install openssh-client openssh-server -y

# Function to create a new user with sudo permissions
create_user() {
  echo "Do you want to create a new user with sudo permissions? (y/n)"
  read -r answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Please enter the username:"
    read -r username
    if id "$username" &>/dev/null; then
      echo "User $username already exists."
    else
      sudo adduser "$username"
      sudo usermod -aG sudo "$username"
      echo "User $username created with sudo permissions."
      sudo usermod -aG docker $USER
      
      # Add 'py' alias to the user's .bashrc
      echo "alias py='python3'" | sudo tee -a "/home/$username/.bashrc"
      echo "Alias 'py' added to /home/$username/.bashrc."
    fi
  else
    echo "Omitting user creation."
  fi
}


# Add 'py' alias to the current user's .bashrc
echo "alias py='python3'" >> ~/.bashrc
echo "alias dir='ls -la'" >> ~/.bashrc

echo "parse_git_branch() {
    git branch 2>/dev/null | grep '\*' | sed 's/* //'
}" >> ~/.bashrc
echo "PS1='\[\e[0;34m\]\h \[\e[1;36m\]\W \[\e[0;32m\]$([[ $(parse_git_branch) ]] && echo "($(parse_git_branch))")\[\e[1;36m\]> \[\e[0m\]' " >> ~/.bashrc

# Install make
echo "Installing make..."
sudo apt install make 

# Install Git
echo "Intalling Git..."
sudo apt install -y git

# Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify the installation
if docker-compose --version &>/dev/null; then
  echo "Docker Compose installed successfully."
else
  echo "Error installing Docker Compose."
fi

# Create a new user with sudo permissions
create_user

# Configure Docker to run without sudo
echo "Setting up Docker to run without sudo..."
sudo usermod -aG docker $USER

# Install other packages
echo "Installing other packages..."
sudo apt install -y curl micro unzip
micro -plugin install filemanager


# Finalización
echo "Setup completed successfully."


# Reboot the system?
echo "Do you want to reboot the system now? (y/n)"
read -r respuesta
if [[ "$respuesta" == "y" || "$respuesta" == "Y" ]]; then
  echo "System rebooting... Connect again in a few seconds."
  sudo reboot
else
  echo "Reboot the system to apply the changes."
fi
