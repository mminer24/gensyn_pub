cat << 'EOF' > install_gensyn_node.sh
#!/bin/bash

SESSION_NAME="gensyn-node"
SWARM_SCRIPT="run_rl_swarm.sh"
REPO_URL="https://github.com/zunxbt/rl-swarm.git"
LOG_DIR="$HOME/gensyn_logs"
VENV_DIR="$HOME/gensyn-venv"
USE_GPU=false  # Zmień na true, jeśli VPS ma GPU

sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git tmux curl unzip

python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate
pip install --upgrade pip

cd ~
if [ ! -d rl-swarm ]; then
    git clone $REPO_URL
fi
cd rl-swarm

pip install -r requirements.txt
if $USE_GPU; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    pip install torch torchvision torchaudio
fi

mkdir -p "$LOG_DIR"

tmux new-session -d -s $SESSION_NAME
tmux send-keys -t $SESSION_NAME "cd ~/rl-swarm" C-m
tmux send-keys -t $SESSION_NAME "source $VENV_DIR/bin/activate" C-m
tmux send-keys -t $SESSION_NAME "bash $SWARM_SCRIPT | tee $LOG_DIR/\$(date +%Y-%m-%d_%H-%M-%S).log" C-m

echo -e "\n✅ Node uruchomiony w tmux: $SESSION_NAME"
echo "➤ tmux attach -t $SESSION_NAME   # podgląd logów"
echo "➤ Ctrl+B, D                       # wyjście z tmux"
EOF
chmod +x install_gensyn_node.sh
