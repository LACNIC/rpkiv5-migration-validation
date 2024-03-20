#!/bin/bash
#############################################################
#
#############################################################

docker_volume="routinator_rpkiv5_cache"
docker_container="routinator_rpkiv5"
docker_image="nlnetlabs/routinator:latest"
#docker_image="nlnetlabs/routinator:v0.12.2"
docker_options="--dns 172.17.0.2 -p 3323:3323 -p 8323:8323"
cli_parameters="--disable-rsync -vv  -r /home/routinator/.rpki-cache --no-rir-tals --extra-tals-dir=/tmp/tals server --refresh=120"

# prune volume
function prune() {
    echo "Pruning cache volume"
    docker volume rm $docker_volume
    docker rm -f $docker_container
    # Add your commands for action1 here
}

# Define validate_current
function current() {
	echo "Validating lacnic rpki against current system (no --add-host)"

    	docker rm -f $docker_container

	docker run --rm  \
        	-v $(pwd)/tals:/tmp/tals \
        	-v $docker_volume:/home/routinator/.rpki-cache \
		$docker_options \
        	--name $docker_container \
        	$docker_image $cli_parameters
}

# Define rpkiv5
function rpkiv5() {
	echo "Validating lacnic rpki against current system (no --add-host)"

	docker run --rm  \
        	-v $(pwd)/tals:/tmp/tals \
        	-v $docker_volume:/home/routinator/.rpki-cache \
		$docker_options \
		--add-host rrdp.lacnic.net:139.144.255.162 \
        	--name $docker_container \
        	$docker_image --disable-rsync -vv  -r /home/routinator/.rpki-cache --no-rir-tals --extra-tals-dir=/tmp/tals server
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
    *)
        echo "Usage: $0 {prune|current|rpkiv5"
        exit 1
esac

exit 0

