
GOSS_VERSION := 0.3.5

all: python3 python3-dev python27 python27-dev pypy pypy-dev

python3:
	docker build -t bearstech/python:3 -f Dockerfile.3 .
	docker tag bearstech/python:3 bearstech/python:3.5
	docker tag bearstech/python:3 bearstech/python:latest

python3-dev:
	docker build -t bearstech/python-dev:3 -f Dockerfile.3-dev .
	docker tag bearstech/python-dev:3 bearstech/python-dev:3.5
	docker tag bearstech/python-dev:3 bearstech/python-dev:latest

python27:
	docker build -t bearstech/python:2.7 -f Dockerfile.27 .
	docker tag bearstech/python:2.7 bearstech/python:2

python27-dev:
	docker build -t bearstech/python-dev:2.7 -f Dockerfile.27-dev .
	docker tag bearstech/python-dev:2.7 bearstech/python-dev:2

pypy:
	docker build -t bearstech/pypy:5.6 -f Dockerfile.pypy .
	docker tag bearstech/pypy:5.6 bearstech/pypy:latest

pypy-dev:
	docker build -t bearstech/pypy-dev:5.6 -f Dockerfile.pypy-dev .
	docker tag bearstech/pypy-dev:5.6 bearstech/pypy-dev:latest

pull:
	docker pull bearstech/debian:stretch

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

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-2: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/python-dev:2 \
		goss -g python-dev.yaml --vars vars/2.yaml validate --max-concurrent 4 --format documentation

test-3: bin/goss
	@rm -rf tests/vendor
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/python-dev:3 \
		goss -g python-dev.yaml --vars vars/3.yaml validate --max-concurrent 4 --format documentation

tests: test-2 test-3
