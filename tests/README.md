Testing image with Goss
=======================

Tests are running inside container context, using volumes and lazy downloaded `goss` binary.

Test are running with the `Makefile` in parent folder, with `make tests`.

`python-dev.yaml`: main playbook. Imports all tests.

`*.yaml` : differents tests.

`vars` : one YAML containing settings per python versions.

`test_install.sh` : dummy shell script for installing stuff with pip.

