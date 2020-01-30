
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.6

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:buster

build: python35 python35-dev python37 python37-dev python27 python27-dev pypy pypy-dev

push:
	docker push bearstech/python:3
	docker push bearstech/python:3.5
	docker push bearstech/python:latest
	docker push bearstech/python-dev:3
	docker push bearstech/python-dev:3.5
	docker push bearstech/python-dev:3.7
	docker push bearstech/python-dev:latest
	docker push bearstech/python:2
	docker push bearstech/python:2.7
	docker push bearstech/python-dev:2
	docker push bearstech/python-dev:2.7
	docker push bearstech/pypy:7
	docker push bearstech/pypy:latest
	docker push bearstech/pypy-dev:7
	docker push bearstech/pypy-dev:latest

remove_image:
	docker rmi bearstech/python:3
	docker rmi bearstech/python:3.5
	docker rmi bearstech/python:latest
	docker rmi bearstech/python-dev:3
	docker rmi bearstech/python-dev:3.5
	docker rmi bearstech/python-dev:3.7
	docker rmi bearstech/python-dev:latest
	docker rmi bearstech/python:2
	docker rmi bearstech/python:2.7
	docker rmi bearstech/python-dev:2
	docker rmi bearstech/python-dev:2.7
	docker rmi bearstech/pypy:7
	docker rmi bearstech/pypy:latest
	docker rmi bearstech/pypy-dev:7
	docker rmi bearstech/pypy-dev:latest

python35:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=stretch \
		-t bearstech/python:3.5 \
		-f Dockerfile.3 \
		.
	docker tag bearstech/python:3.5 bearstech/python:3
	docker tag bearstech/python:3.5 bearstech/python:latest

python35-dev: python35
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=stretch \
		-t bearstech/python-dev:3.5 \
		-f Dockerfile.3-dev \
		.
	docker tag bearstech/python-dev:3.5 bearstech/python-dev:3
	docker tag bearstech/python-dev:3.5 bearstech/python-dev:latest

python37:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=buster \
		-t bearstech/python:3.7 \
		-f Dockerfile.3 \
		.

python37-dev: python37
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=buster \
		-t bearstech/python-dev:3.7 \
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

pypy:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/pypy:7 \
		-f Dockerfile.pypy \
		.
	docker tag bearstech/pypy:7 bearstech/pypy:latest

pypy-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/pypy-dev:7 \
		-f Dockerfile.pypy-dev \
		.
	docker tag bearstech/pypy-dev:7 bearstech/pypy-dev:latest

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-2: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:2 \
		goss -g python-dev.yaml --vars vars/2.yaml validate --max-concurrent 4 --format documentation

test-35: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:3.5 \
		goss -g python-dev.yaml --vars vars/35.yaml validate --max-concurrent 4 --format documentation

test-37: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:3.7 \
		goss -g python-dev.yaml --vars vars/37.yaml validate --max-concurrent 4 --format documentation

test-pypy: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/pypy-dev:7 \
		goss -g python-dev.yaml --vars vars/pypy.yaml validate --max-concurrent 4 --format documentation

down:

tests: test-2 test-35 test-37 test-pypy
