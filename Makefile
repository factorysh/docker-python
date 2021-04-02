
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.16

all: pull build

pull:
	docker pull bearstech/debian:buster

build: python37 python37-dev python27 python27-dev

push:
	docker push bearstech/python:3
	docker push bearstech/python:latest
	docker push bearstech/python-dev:3
	docker push bearstech/python-dev:3.7
	docker push bearstech/python-dev:latest
	docker push bearstech/python:2
	docker push bearstech/python:2.7
	docker push bearstech/python-dev:2
	docker push bearstech/python-dev:2.7

remove_image:
	docker rmi bearstech/python:3
	docker rmi bearstech/python:latest
	docker rmi bearstech/python-dev:3
	docker rmi bearstech/python-dev:3.7
	docker rmi bearstech/python-dev:latest
	docker rmi bearstech/python:2
	docker rmi bearstech/python:2.7
	docker rmi bearstech/python-dev:2
	docker rmi bearstech/python-dev:2.7

python37:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=buster \
		-t bearstech/python:3.7 \
		-f Dockerfile.3 \
		.
	docker tag bearstech/python:3.7 bearstech/python:3
	docker tag bearstech/python:3.7 bearstech/python:latest

python39:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=bullseye \
		-t bearstech/python:3.9 \
		-f Dockerfile.3 \
		.

python37-dev: python37
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=buster \
		-t bearstech/python-dev:3.7 \
		-f Dockerfile.3-dev \
		.
	docker tag bearstech/python-dev:3.7 bearstech/python-dev:3
	docker tag bearstech/python-dev:3.7 bearstech/python-dev:latest

python39-dev: python39
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=bullseye \
		-t bearstech/python-dev:3.9 \
		-f Dockerfile.3-dev \
		.
python27:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/python:2.7 \
		-f Dockerfile.27 \
		.
	docker tag bearstech/python:2.7 bearstech/python:2

python27-dev: python27
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/python-dev:2.7 \
		-f Dockerfile.27-dev \
		.
	docker tag bearstech/python-dev:2.7 bearstech/python-dev:2

goss: bin/goss-${GOSS_VERSION}

bin/goss-${GOSS_VERSION}:
	mkdir -p bin
	curl -o bin/goss-${GOSS_VERSION} -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss-${GOSS_VERSION}
	cd bin && ln -sf goss-${GOSS_VERSION} goss

test-2: goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:2 \
		goss -g python-dev.yaml --vars vars/2.yaml validate --max-concurrent 4 --format documentation

test-37: goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:3.7 \
		goss -g python-dev.yaml --vars vars/37.yaml validate --max-concurrent 4 --format documentation

test-39: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:3.9 \
		goss -g python-dev.yaml --vars vars/39.yaml validate --max-concurrent 4 --format documentation

down:

tests: test-2 test-37
