#!/bin/bash
#


# Docker server
docker_server="docker.io"

# Docker repo
docker_repo="motornyuk/nmap"

# GiHub repo
gitlab_repo="motornyuk/nmap_docker_image.git"

# Log file
declare -r log="./log_build.log"
cat /dev/null > $log

# Generate timestamp
function timestamp() {
  date +"%Y%m%d_%H%M%S"
}

# Log and Print
logger() {
    printf "$1\n"
    printf "$(timestamp) - $1\n" >> $log
}

# Assign timestamp to ensure var is a static point in time.
declare -r timestp=$(timestamp)
logger "Starting Build. Timestamp: $timestp\n"

# Build the image using timestamp as tag.
function build() {
  local cmd
  cmd="docker build . -t docker.io/${docker_repo}:$timestp >> $log"
  logger "Running Docker Build Command: \"$cmd\""
  docker build . -t "${docker_server}"/"${docker_repo}":$timestp >> $log || logger "Error! docker build failed"
}

# Push to github - Triggers builds in github and Dockerhub.
function git() {
  git="/usr/bin/git -C ./"
  $git -C './' pull git@github.com:"${gitlab_repo}" >> $log || { echo "git pull failed!"; exit 1; }
  $git add --all >> $log || { echo "git add failed!"; exit 1; }
  $git commit -a -m 'Automatic build '$timestp >> $log || { echo "git commit failed!"; exit 1; }
  $git push >> $log || { echo "git push failed!"; exit 1; }
} 

# Push the new tag to Dockerhub.
function docker_push() {
  echo "Pushing ${docker_repo}:$timestp..."
  docker push "${docker_repo}":$timestp >> $log || { echo "docker image ${docker_repo}:$timestp push failed!"; exit 1; }
  echo "Tagging ${docker_repo}:$timestp..."
  docker tag "${docker_repo}":$timestp docker.io/"${docker_repo}":latest >> $log || { echo "docker image ${docker_repo}:$timestp tag failed!"; exit 1; }
  echo "Pushing ${docker_repo}:latest..."
  docker push "${docker_repo}":latest >> $log || { echo "docker image ${docker_repo}:latest push failed!"; exit 1; }
}

# Prune the git tree in the local dir
function prune() {
  logger "Running git gc --prune"
  /usr/bin/git gc --prune 
}


function main() {
build
git
docker_push
prune
logger "All complete."
}

main
