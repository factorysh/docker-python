
all: python3 python3-dev python27 python27-dev

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
	docker tag bearstech/python:2.7 bearstech:python:2

python27-dev:
	docker build -t bearstech/python-dev:2.7 -f Dockerfile.27-dev .
	docker tag bearstech/python-dev:2.7 bearstech/python-dev:2
