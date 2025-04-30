cat << 'EOF' > update_gensyn_node.sh
#!/bin/bash

SESSION_NAME="gensyn-node"
REPO_DIR="$HOME/rl-swarm"

echo "🔄 Aktualizacja node'a Gensyn..."

if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux kill-session -t $SESSION_NAME
fi

cd "$REPO_DIR" || { echo "❌ Nie znaleziono $REPO_DIR"; exit 1; }
git pull

tmux new-session -d -s $SESSION_NAME
tmux send-keys -t $SESSION_NAME "source $HOME/gensyn-venv/bin/activate" C-m
tmux send-keys -t $SESSION_NAME "cd $REPO_DIR" C-m
tmux send-keys -t $SESSION_NAME "bash run_rl_swarm.sh | tee $HOME/gensyn_logs/\$(date +%Y-%m-%d_%H-%M-%S).log" C-m

echo "✅ Node zaktualizowany i uruchomiony w tmux: $SESSION_NAME"
EOF
chmod +x update_gensyn_node.sh
