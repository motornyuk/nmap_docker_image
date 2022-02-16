#!/usr/bin/env bash
#

# Docker server
docker_server="docker.io"

# Docker repo
docker_repo="motornyuk/nmap"

# Git server
git_server="git@github.com"

# Git repo
git_repo="motornyuk/nmap_docker_image.git"

# App version
app_version="7.92-1"

# Log file
declare -r log="./log_build.log"
cat /dev/null > ${log}

# Generate timestamp
function timestamp() {
  date +"%Y%m%d_%H%M%S"
}

# Log and Print
logger() {
    printf "$1\n"
    printf "$(timestamp) - $1\n" >> ${log}
}

# Exception Catcher
except () {
    logger $1
    return 1
}

# Assign timestamp to ensure var is a static point in time.
declare -r timestp=$(timestamp)
logger "Starting Build. Timestamp: ${timestp}\n"

# Build the image using timestamp as tag.
function build() {
  local cmd
  cmd="docker build . -t ${docker_server}/${docker_repo}:${app_version} >> ${log}"
  logger "Running Docker Build Command: \"$cmd\""
  docker build . -t "${docker_server}"/"${docker_repo}":"${app_version}" >> ${log} || except "Error! docker build failed"
}

# Push to github - Triggers builds in github and Dockerhub.
function git() {
  git="/usr/bin/git -C ./"
  ${git} -C './' pull "${git_server}":"${git_repo}" >> ${log} || except "git pull failed!"
  ${git} add --all >> ${log} || except "git add failed!"
  ${git} commit -a -m 'Automatic build '${app_version} >> ${log} || except "git commit failed!"
  ${git} push >> ${log} || except "git push failed!"
} 

# Push the new tag to Dockerhub.
function docker_push() {
  echo "Pushing ${docker_repo}:${app_version}..."
  docker push "${docker_repo}:${app_version}" >> ${log} || except "docker image ${docker_repo}:${app_version} push failed!"
  echo "Tagging ${docker_repo}:${app_version}..."
  docker tag "${docker_repo}:${app_version}" "${docker_server}"/"${docker_repo}":latest >> ${log} || except "docker image ${docker_repo}:${app_version} tag failed!"
  echo "Pushing ${docker_repo}:latest..."
  docker push "${docker_repo}":latest >> ${log} || except "docker image ${docker_repo}:latest push failed!"
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
