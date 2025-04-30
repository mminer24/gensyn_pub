#!/bin/bash

# === Ustawienia ===
SESSION_NAME="gensyn-node"
SWARM_SCRIPT="run_rl_swarm.sh"
REPO_URL="https://github.com/zunxbt/rl-swarm.git"
LOG_DIR="$HOME/gensyn_logs"
VENV_DIR="$HOME/gensyn-venv"
USE_GPU=false  # Zmień na true, jeśli VPS ma GPU

# === Aktualizacja systemu i pakietów ===
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git tmux curl unzip -y

# === Tworzenie środowiska Python ===
python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate
pip install --upgrade pip

# === Klonowanie repozytorium ===
cd ~
if [ ! -d rl-swarm ]; then
    git clone $REPO_URL
fi
cd rl-swarm

# === Instalacja zależności ===
pip install -r requirements.txt
if $USE_GPU; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    pip install torch torchvision torchaudio
fi

# === Logi ===
mkdir -p "$LOG_DIR"

# === Uruchomienie node'a w tmux ===
tmux new-session -d -s $SESSION_NAME
tmux send-keys -t $SESSION_NAME "cd ~/rl-swarm" C-m
tmux send-keys -t $SESSION_NAME "source $VENV_DIR/bin/activate" C-m
tmux send-keys -t $SESSION_NAME "bash $SWARM_SCRIPT | tee $LOG_DIR/\$(date +%Y-%m-%d_%H-%M-%S).log" C-m

# === Sprawdzenie, czy sesja została utworzona ===
sleep 2
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo -e "\n✅ Node został uruchomiony w tle!"
    echo -e "🔍 Aby podejrzeć logi w innym oknie terminala, wklej:"
    echo -e "\n  \033[1;32mtmux attach -t $SESSION_NAME\033[0m\n"
    echo -e "➡️  Aby wyjść z logów bez zatrzymania node’a: Ctrl+B, potem D"
else
    echo -e "\n❌ Coś poszło nie tak – sesja tmux się nie uruchomiła."
    echo "Sprawdź logi ręcznie lub uruchom ręcznie: bash ~/rl-swarm/run_rl_swarm.sh"
fi
