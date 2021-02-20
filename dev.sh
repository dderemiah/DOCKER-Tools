#!/bin/zsh
# docker-compose up --build
docker build -t vpackets-tools-wrs . && \
docker run -dit --name devops_tools -h vpackets-container \
-v /dpool/ISOs/:/home/danield/lab-images \
-v /dpool/git_projects/:/home/danield/code \
-v /dpool/git_projects/DOCKER-Tools/Ansible/Ansible_variables:/home/danield/ansible \
vpackets-tools-wrs:latest && \
docker exec -it --user danield devops_tools tmux new-session -d -s dock
