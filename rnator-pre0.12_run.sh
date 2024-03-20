#!/bin/bash
#############################################################
#
#############################################################

docker_volume="routinator_rpkiv5_cache"
docker_container="routinator_rpkiv5"
#docker_image="nlnetlabs/routinator:latest"
docker_image="nlnetlabs/routinator:v0.10.1"
docker_options="-d -p:3323:3323 -p 8323:8323"
#
routinator_cli="--disable-rsync -vv  -r /home/routinator/.rpki-cache server --http 0.0.0.0:8323"
# routinator_cli="-vv  -r /home/routinator/.rpki-cache server"

# prune volume
function prune() {
    echo "Pruning cache volume"
    docker rm -f $docker_container
    docker volume rm $docker_volume
    # Add your commands for action1 here
}

# Define validate_current
function current() {
	echo "Validating lacnic rpki against current system (no --add-host)"
	echo "Using image: $docker_image"

	docker rm -f $docker_container 

	docker run --rm \
        	-v $docker_volume:/home/routinator/.rpki-cache \
        	-v $(pwd)/tals:/home/routinator/.rpki-cache/tals \
		$docker_options \
        	--name $docker_container \
		$docker_image $routinator_cli
}

# Define rpkiv5
function rpkiv5() {
	echo "Validating lacnic rpki against rpkiv5 system (full --add-host)"
	echo "Using image: $docker_image"

	docker rm -f $docker_container 

	docker run --rm  \
        	-v $docker_volume:/home/routinator/.rpki-cache \
        	-v $(pwd)/tals:/home/routinator/.rpki-cache/tals \
		$docker_options \
		--add-host rrdp.lacnic.net:139.144.255.162 \
        	--name $docker_container \
		$docker_image $routinator_cli
}

function logsf() {
	echo "Following logs"
	docker logs -f --timestamps $docker_container
}

# Check command-line arguments
case "$1" in
    prune)
       prune 
        ;;
    current)
       current 
        ;;
    rpkiv5)
       rpkiv5 
        ;;
    logsf)
       logsf 
        ;;
    *)
        echo "Usage: $0 {prune|current|rpkiv5"
        exit 1
esac

exit 0

