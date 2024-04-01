#!/bin/bash
#############################################################
#
#############################################################

docker_volume="fort_rpkiv5_cache"
docker_container="fort_rpkiv5"
docker_image="nicmx/fort-validator:latest"
# docker_image="nicmx/fort-validator:1.5.3"
# docker_image="nicmx/fort-validator:1.6.0"
# docker_options="--dns 172.17.0.2 -p:3324:3323 -p 8324:8323"
docker_options="-p:3324:3323 -p 8324:8323"
rpkiv5_host="96.126.99.186"
#
# cli_parameters="--server.interval.validation 120 --rsync.enabled=false --tal=/etc/tals/lacnic.tal --output.roa=/root/lacnic_vrps.csv --local-repository=/root/cache --log.output console --log.level=debug --validation-log.enabled=true"
cli_parameters="--server.interval.validation 120 --rsync.enabled=true --http.enabled=false --tal=/etc/tals/lacnic.tal --output.roa=/root/lacnic_vrps.csv --local-repository=/root/cache --log.output console --log.level=debug --validation-log.enabled=true"

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
        	-v $docker_volume:/root/cache \
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
		--add-host repository.lacnic.net:$rpkiv5_host \
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

