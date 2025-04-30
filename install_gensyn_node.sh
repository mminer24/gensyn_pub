#!/bin/bash

# === Ustawienia ===
SESSION_NAME="gensyn-node"
SWARM_SCRIPT="run_rl_swarm.sh"
REPO_URL="https://github.com/zunxbt/rl-swarm.git"
LOG_DIR="$HOME/gensyn_logs"
VENV_DIR="$HOME/gensyn-venv"
USE_GPU=false  # Zmień na true, jeśli VPS ma GPU

# === Sprawdzenie portu 3000 ===
echo -e "\n=== [⚙] Sprawdzanie czy port 3000 jest zajęty ==="
PORT=3000
PIDS=$(lsof -t -i tcp:$PORT || true)

if [ -n "$PIDS" ]; then
    echo -e "\033[33m[WARNING]\033[0m Port $PORT jest zajęty. Zajęte przez PID: $PIDS"
    for PID in $PIDS; do
        PROC_NAME=$(ps -p $PID -o comm=)
        echo " → Zabijanie procesu: $PROC_NAME (PID $PID)"
        kill -9 $PID
    done
    sleep 2
    echo -e "\033[32m[OK]\033[0m Port $PORT został zwolniony."
else
    echo -e "\033[32m[OK]\033[0m Port $PORT jest wolny."
fi

# === Instalacja zależności systemowych ===
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git tmux curl unzip lsof

# === Tworzenie środowiska Python ===
python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate
pip install --upgrade pip

# === Klonowanie repozytorium rl-swarm ===
cd ~
if [ ! -d rl-swarm ]; then
    git clone $REPO_URL
fi
cd rl-swarm

# === Instalacja zależności Python ===
pip install -r requirements.txt
if $USE_GPU; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    pip install torch torchvision torchaudio
fi

# === Katalog logów ===
mkdir -p "$LOG_DIR"

# === Uruchamianie node'a Gensyn w tmux (z auto N) ===
tmux new-session -d -s $SESSION_NAME
tmux send-keys -t $SESSION_NAME "cd ~/rl-swarm" C-m
tmux send-keys -t $SESSION_NAME "source $VENV_DIR/bin/activate" C-m
tmux send-keys -t $SESSION_NAME "echo N | bash $SWARM_SCRIPT | tee $LOG_DIR/\$(date +%Y-%m-%d_%H-%M-%S).log" C-m

# === Informacja końcowa ===
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
