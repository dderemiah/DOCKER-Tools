#!/bin/zsh
docker-compose up --build && \
docker exec -it --user danield devops_tools tmux new-session -d -s dock
