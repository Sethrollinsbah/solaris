# Start a new tmux session named "devenv"
tmux new-session -s devenv

# In the first window, run the database in Docker
docker-compose up db -d

# Change to the res-ads directory and run the frontend dev server
cd res-ads
bun run dev
