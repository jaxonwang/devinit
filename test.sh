
# install docker if not exist
command -v docker || (curl -fsSL https://get.docker.com -o get-docker.sh | sh)

docker build -f ./DockerfileU .

