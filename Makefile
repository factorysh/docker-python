GOSS_VERSION := 0.3.6
GIT_VERSION := $(shell git rev-parse HEAD)
GIT_DATE := $(shell git show -s --format=%ci HEAD)

all: pull build

pull:
	docker pull bearstech/debian:stretch

build: python3 python3-dev python27 python27-dev pypy pypy-dev pypy-7 pypy-7-dev

push:
	docker push bearstech/python:3
	docker push bearstech/python:3.5
	docker push bearstech/python:latest
	docker push bearstech/python-dev:3
	docker push bearstech/python-dev:3.5
	docker push bearstech/python-dev:latest
	docker push bearstech/python:2
	docker push bearstech/python:2.7
	docker push bearstech/python-dev:2
	docker push bearstech/python-dev:2.7
	docker push bearstech/pypy:5.6
	docker push bearstech/pypy:latest
	docker push bearstech/pypy-dev:5.6
	docker push bearstech/pypy-dev:latest

remove_image:
	docker rmi bearstech/python:3
	docker rmi bearstech/python:3.5
	docker rmi bearstech/python:latest
	docker rmi bearstech/python-dev:3
	docker rmi bearstech/python-dev:3.5
	docker rmi bearstech/python-dev:latest
	docker rmi bearstech/python:2
	docker rmi bearstech/python:2.7
	docker rmi bearstech/python-dev:2
	docker rmi bearstech/python-dev:2.7
	docker rmi bearstech/pypy:5.6
	docker rmi bearstech/pypy:latest
	docker rmi bearstech/pypy-dev:5.6
	docker rmi bearstech/pypy-dev:latest

python3:
	docker build \
		-t bearstech/python:3 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.3 \
		.
	docker tag bearstech/python:3 bearstech/python:3.5
	docker tag bearstech/python:3 bearstech/python:latest

python3-dev: python3
	docker build \
		-t bearstech/python-dev:3 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.3-dev \
		.
	docker tag bearstech/python-dev:3 bearstech/python-dev:3.5
	docker tag bearstech/python-dev:3 bearstech/python-dev:latest

python27:
	docker build \
		-t bearstech/python:2.7 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.27 \
		.
	docker tag bearstech/python:2.7 bearstech/python:2

python27-dev: python27
	docker build \
		-t bearstech/python-dev:2.7 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.27-dev \
		.
	docker tag bearstech/python-dev:2.7 bearstech/python-dev:2

pypy:
	docker build \
		-t bearstech/pypy:5.6 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.pypy \
		.
	docker tag bearstech/pypy:5.6 bearstech/pypy:latest

pypy-dev:
	docker build \
		-t bearstech/pypy-dev:5.6 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.pypy-dev \
		.
	docker tag bearstech/pypy-dev:5.6 bearstech/pypy-dev:latest

pypy-7:
	docker build \
		-t bearstech/pypy:7 \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		--build-arg PYPY_VERSION=${PYPY_VERSION} \
		-f Dockerfile.pypy-7 \
		.

pypy-7-dev:
	docker build \
		-t bearstech/pypy-dev:7 \
		--build-arg PYPY_VERSION=${PYPY_VERSION} \
		--build-arg GIT_VERSION=${GIT_VERSION} \
		--build-arg GIT_DATE="${GIT_DATE}" \
		-f Dockerfile.pypy-7-dev \
		.

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

test-3: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:3 \
		goss -g python-dev.yaml --vars vars/3.yaml validate --max-concurrent 4 --format documentation

test-pypy: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/pypy-dev:5.6 \
		goss -g python-dev.yaml --vars vars/pypy.yaml validate --max-concurrent 4 --format documentation

test-pypy7: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/pypy-dev:7 \
		goss -g python-dev.yaml --vars vars/pypy7.yaml validate --max-concurrent 4 --format documentation

down:

tests: test-2 test-3 test-pypy
