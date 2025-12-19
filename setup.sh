#!/bin/bash

# Detener el script si hay un error crítico
set -e

# --- Update and upgrade the system ---
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y
# Instalamos dependencias básicas necesarias (incluyendo curl para bajar miniforge)
sudo apt install -y openssh-client openssh-server lsb-release ca-certificates apt-transport-https software-properties-common curl wget git make

# --- Configuración del .bashrc (Variable para reutilizar) ---
CONFIG_BASHRC=$(cat << 'EOF'

# --- Custom Aliases and Prompt ---
alias py='python3'
alias dir='ls -la'

parse_git_branch() {
    git branch 2>/dev/null | grep '\*' | sed 's/* //'
}
PS1='\[\e[0;34m\]\h \[\e[1;36m\]\W \[\e[0;32m\]$([[ $(parse_git_branch) ]] && echo "($(parse_git_branch))")\[\e[1;36m\]> \[\e[0m\]'
# ---------------------------------
EOF
)

# --- Function to create a new user ---
create_user() {
  echo "Do you want to create a new user with sudo permissions? (y/n)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Please enter the username:"
    read -r username
    if id "$username" &>/dev/null; then
      echo "User $username already exists."
    else
      # Se asume que Docker ya se instaló antes de llamar a esta función
      sudo adduser "$username"
      sudo usermod -aG sudo "$username"
      sudo usermod -aG docker "$username"
      echo "User $username created with sudo and docker permissions."
      
      # Add configuration to the new user's .bashrc
      echo "$CONFIG_BASHRC" | sudo tee -a "/home/$username/.bashrc" > /dev/null
      echo "Aliases and git prompt added to /home/$username/.bashrc."
    fi
  else
    echo "Omitting user creation."
  fi
}

# --- Apply Config to Current User ---
echo "$CONFIG_BASHRC" >> ~/.bashrc
echo "Aliases and git prompt added to current user's .bashrc."

# --- Install Docker ---
echo "Installing Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
# Instalamos docker y el plugin moderno de compose
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configure Docker to run without sudo for current user
echo "Setting up Docker to run without sudo for current user..."
sudo usermod -aG docker "$USER"

# --- Install Other Packages ---
echo "Installing other packages (micro, unzip)..."
sudo apt install -y micro unzip

if command -v micro &> /dev/null; then
    micro -plugin install filemanager
fi

# --- Install Miniforge (Conda) ---
echo "Checking Miniforge installation..."
# Verificamos si ya existe para no reinstalar encima
if [ ! -d "$HOME/miniforge3" ]; then
    echo "Downloading and Installing Miniforge..."
    
    # Nombre dinámico del archivo basado en el sistema (ej: Miniforge3-Linux-x86_64.sh)
    MINIFORGE_FILE="Miniforge3-$(uname)-$(uname -m).sh"
    MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/$MINIFORGE_FILE"
    
    # Descargar
    curl -L -O "$MINIFORGE_URL"
    
    # Instalar:
    # -b: Batch mode (sin preguntas, acepta licencia auto)
    # -p: Path (ruta de instalación)
    bash "$MINIFORGE_FILE" -b -p "$HOME/miniforge3"
    
    # Borrar el instalador
    rm "$MINIFORGE_FILE"
    
    # Inicializar conda para bash
    "$HOME/miniforge3/bin/conda" init bash
    
    # Configuración opcional: No activar 'base' por defecto al abrir terminal
    "$HOME/miniforge3/bin/conda" config --set auto_activate_base false
    
    echo "Miniforge installed successfully in $HOME/miniforge3"
else
    echo "Miniforge directory ($HOME/miniforge3) already exists. Skipping."
fi

# --- Create User Step ---
# Llamamos a esto al final para que no interfiera con las instalaciones del usuario actual
create_user

# --- Finalization ---
echo "Setup completed successfully."
echo "Do you want to reboot the system now? (y/n)"
read -r respuesta
if [[ "$respuesta" =~ ^[Yy]$ ]]; then
  echo "System rebooting..."
  sudo reboot
else
  echo "PLEASE NOTE: You must log out and log back in (or run 'source ~/.bashrc') to use Conda and Docker."
fi
