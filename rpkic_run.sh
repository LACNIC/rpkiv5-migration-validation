#!/bin/bash
#############################################################
# Correr RPKI Client
#############################################################

docker_volume="rpkic_rpkiv5_cache"
docker_container="rpkic_rpkiv5"
# docker_image="rpki/rpki-client:9.0"
docker_image="rpki/rpki-client:8.2"
# docker_image="rpki/rpki-client:7.7"
# docker_image="rpki/rpki-client:7.0"
# docker_options="--dns 172.17.0.2 -p:3323:3323 -p 8323:8323"
docker_options="-d --dns 172.17.0.2"
rpkiv5_host="96.126.99.186"
#
cli_parameters="-s 480 -c -v -v -v"

# prune volume
function prune() {
    echo "Pruning cache volume"
    docker rm -f $docker_container
    docker volume rm $docker_volume
}

# Define validate_current
function current() {
	echo "Validating lacnic rpki against current system (no --add-host)"
	echo "Using image: $docker_image"

	docker rm -f $docker_container 

	docker run --rm \
        	-v $docker_volume:/var/cache/rpki-client \
        	-v $(pwd)/tals:/etc/tals \
		$docker_options \
        	--name $docker_container \
		$docker_image $cli_parameters
}

# Define rpkiv5
function rpkiv5() {
	echo "Validating lacnic rpki against rpkiv5 system (full --add-host)"
	echo "Using image: $docker_image"

	docker rm -f $docker_container 

	docker run --rm \
        	-v $docker_volume:/root/cache \
        	-v $(pwd)/tals:/etc/tals \
		--add-host rrdp.lacnic.net:$rpkiv5_host \
		$docker_options \
        	--name $docker_container \
		$docker_image $cli_parameters
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

