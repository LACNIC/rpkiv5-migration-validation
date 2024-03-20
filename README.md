# rpkiv5-migration-validation

Set of scripts used to validate the migration flow for LACNIC's RPKI

Each RP gets a script that launches a docker container.

Each script has two actions: current (validates against LACNIC's current repo) and rpkiv5 (validates against the new system).

Each container uses a persistent volume to keep the RPs cache between container runs. Each script has some variables that can be tweaked (image name, etc.). If no dnsmasq is used make sure to comment out the "--dns" option.

## Emulate Migration Workflow

1. Run the RP against the current system: ```./fort_run.sh current```
2. Wait for the first run to finish and it's cache is populated
3. Stop the running container (CTRL+C if you are running a non-datached container, use docker rm -f if you are running a detached container)
4. Run the RP against the new system: ```./fort_run.sh rpkiv5```. This run will use the "--add-host" docker option to 'lie' to the container and make it believe rrdp.lacnic.net now is the IP the new system.
5. Check the outputs of the first and second runs. Both should return a valid number of VRPs, being the main difference now that NIC.br's child CA is not yet replicated in the new system.
