ifndef CONTAINER
CONTAINER=squid
endif

build:
	docker build --no-cache -t $(CONTAINER) -f .docker/Dockerfile .
run:
	docker container run \
		-d \
		-v ${PWD}/cache/:/var/cache/squid/ \
		-v ${PWD}/log/:/var/log/ \
		-v ${PWD}/cert/:/etc/squid-cert/ \
		--read-only -v ${PWD}/squid.conf:/etc/squid/squid.conf \
		--name squid \
		$(CONTAINER)
exec:
	docker exec -it squid /bin/bash
clean:
	docker stop squid && docker rm squid && docker image rm squid
configure:
	sudo docker exec squid squid -k reconfigure -f /etc/squid/squid.conf
