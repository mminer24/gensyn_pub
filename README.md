cat << 'EOF' > README.md
# 🧠 Gensyn Node – Automatyczna instalacja i aktualizacja

To repozytorium zawiera skrypty do uruchomienia i zarządzania nodem Gensyn na VPS z systemem Ubuntu.

## ⚙️ Instalacja node'a (jedną komendą)

```bash
bash <(curl -s https://raw.githubusercontent.com/mminer24/gensyn_pub/main/install_gensyn_node.sh)

###  Aktualizacja node’a

```bash
bash <(curl -s https://raw.githubusercontent.com/mminer24/gensyn_pub/main/update_gensyn_node.sh)

📄 Obsługa tmux
	•	tmux attach -t gensyn-node – podgląd logów
	•	Ctrl + B, potem D – wyjście bez zatrzymania node’a

✅ Wymagania
	•	Ubuntu 20.04 / 22.04
	•	Python 3.8+
	•	(Opcjonalnie) GPU z CUDA

Repozytorium źródłowe node’a: https://github.com/zunxbt/rl-swarm
EOF

---

### 📌 4. Wypchnij wszystko na GitHuba

git add README.md
git commit -m “✅ Poprawione formatowanie README.md”
git push origin main
