#!/bin/bash
# 🌐 GENSYN RL-SWARM GPU Installer (based on working config 2025-08-25)
# Autor: Przyjacielu + ChatGPT

set -e

echo "========== 🚀 GENSYN INSTALLER (GPU) =========="
echo "[1/9] Aktualizacja systemu..."
sudo apt update && sudo apt upgrade -y

echo "[2/9] Instalacja zależności systemowych..."
sudo apt install -y python3 python3-pip git tmux wget curl unzip build-essential

echo "[3/9] Sprawdzanie GPU..."
if ! command -v nvidia-smi &> /dev/null; then
  echo "❌ Nie wykryto nvidia-smi – brak sterowników GPU?"
else
  nvidia-smi
fi

echo "[4/9] Klonowanie rl-swarm..."
cd ~
rm -rf rl-swarm
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm

echo "[5/9] Tworzenie i aktywacja środowiska Python (venv)..."
python3 -m venv .venv
source .venv/bin/activate

echo "[6/9] Instalacja hivemind i poprawka protobuf..."
pip install --upgrade pip
pip uninstall -y hivemind
pip install hivemind==1.2.0.dev0
pip install protobuf==4.25.3

echo "[7/9] Konfiguracja yarn w modal-login..."
cd ~/rl-swarm/modal-login

yarn set version stable
yarn config set enableImmutableInstalls false
echo "nodeLinker: node-modules" >> .yarnrc.yml
yarn add viem@2.29.2
yarn install

echo "[8/9] Gotowe! Uruchamianie Gensyn w tmux..."
cd ~/rl-swarm
tmux new-session -d -s gensyn 'bash run_rl_swarm.sh | tee ~/rl-swarm/rlswarm.log'

echo "[9/9] ✔ Instalacja zakończona! Aby podejrzeć logi:"
echo "  tmux attach -t gensyn"
echo "  tail -f ~/rl-swarm/rlswarm.log"
echo "==============================================="
