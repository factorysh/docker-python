
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.16

all: pull build

pull:
	docker pull bearstech/debian:buster
	docker pull bearstech/debian:bullseye

build: python-2.7-buster python_dev-2.7-buster \
	python-3.5-stretch python_dev-3.5-stretch \
	python-3.7-buster python_dev-3.7-buster \
	python-3.9-bullseye python_dev-3.9-bullseye
	docker tag bearstech/python:2.7 bearstech/python:2
	docker tag bearstech/python-dev:2.7 bearstech/python-dev:2
	docker tag bearstech/python:3.9 bearstech/python:3
	docker tag bearstech/python-dev:3.9 bearstech/python-dev:3

push-%:
	$(eval version=$(shell echo $@ | cut -d- -f2))
	docker push bearstech/python:$(version)
	docker push bearstech/python-dev:$(version)

push: push-2.7 push-2 push-3.5 push-3.7 push-3.9 push-3

remove_image:
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/python-dev") || true
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/python") || true


python-%:
	$(eval version=$(shell echo $@ | cut -d- -f2))
	$(eval major_version=$(shell echo $(version) | cut -d. -f1))
	$(eval debian_version=$(shell echo $@ | cut -d- -f3))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=$(debian_version) \
		-t bearstech/python:$(version) \
		-f Dockerfile.$(major_version) \
		.

python_dev-%:
	$(eval version=$(shell echo $@ | cut -d- -f2))
	$(eval major_version=$(shell echo $(version) | cut -d. -f1))
	$(eval debian_version=$(shell echo $@ | cut -d- -f3))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg=DEBIAN_VERSION=$(debian_version) \
		-t bearstech/python-dev:$(version) \
		-f Dockerfile.$(major_version)-dev \
		.

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-%: bin/goss
	$(eval version=$(shell echo $@ | cut -d- -f2))
	@rm -rf tests/vendor
	docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_python:/goss \
		-w /goss \
		bearstech/python-dev:$(version) \
		goss -g python-dev.yaml --vars vars/$(version).yaml validate --max-concurrent 4 --format documentation



tests: test-2.7 test-3.5 test-3.7 test-3.9

down:
