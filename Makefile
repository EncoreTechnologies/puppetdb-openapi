# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL := /bin/bash

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYMODULE_DIR := $(ROOT_DIR)
PYMODULE_TESTS_DIR ?= $(PYMODULE_DIR)/tests
PYMODULE_NAME = $(shell python $(PYMODULE_DIR)/setup.py --name )
YAML_FILES := $(shell git ls-files '*.yaml' '*.yml')
SPEC_YAML_FILES := $(shell git ls-files 'specs/*.yaml' 'specs/*.yml')
JSON_FILES := $(shell git ls-files '*.json')
PY_FILES   := $(shell git ls-files '*.py')
# Virtual Environment
VIRTUALENV_DIR ?= $(ROOT_DIR)/virtualenv
VIRTUALENV_FLAGS := --no-site-packages
# https://stackoverflow.com/a/22105036/1134951
# PYV=$(shell python -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)");
# ifneq ($(PYV),2.7)
#     VIRTUALENV_FLAGS += -p python2.7
# endif


# Run all targets
.PHONY: all
all: validate

.PHONY: clean
clean: .clean-virtualenv .clean-pyc .clean-repos

.PHONY: validate
validate: requirements .validate

# list all makefile targets
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs


.PHONY: .clean-pyc
.clean-pyc:
	@echo "==================== clean *.pyc ===================="
	find $(ROOT_DIR) -name 'virtualenv' -prune -or -name '.git' -or -type f -name "*.pyc" -print | xargs --no-run-if-empty rm 


.PHONY: virtualenv
virtualenv: $(VIRTUALENV_DIR)/bin/activate
$(VIRTUALENV_DIR)/bin/activate:
	@echo "==================== virtualenv ===================="
	test -d $(VIRTUALENV_DIR) || virtualenv $(VIRTUALENV_FLAGS) $(VIRTUALENV_DIR)
# Setup PYTHONPATH in bash activate script...
# Delete existing entries (if any)
	sed $(SED_INPLACE_FLAGS) '/_OLD_PYTHONPATHp/d' $(VIRTUALENV_DIR)/bin/activate
	sed $(SED_INPLACE_FLAGS) '/PYTHONPATH=/d' $(VIRTUALENV_DIR)/bin/activate
	sed $(SED_INPLACE_FLAGS) '/export PYTHONPATH/d' $(VIRTUALENV_DIR)/bin/activate
	echo '_OLD_PYTHONPATH=$$PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate
	echo 'PYTHONPATH=${ROOT_DIR}' >> $(VIRTUALENV_DIR)/bin/activate
	echo 'export PYTHONPATH' >> $(VIRTUALENV_DIR)/bin/activate
	touch $(VIRTUALENV_DIR)/bin/activate


.PHONY: .clean-virtualenv
.clean-virtualenv:
	@echo "==================== cleaning virtualenv ===================="
	rm -rf $(VIRTUALENV_DIR)


.PHONY: requirements
requirements: virtualenv
	@echo
	@echo "==================== requirements ===================="
	@echo
	. $(VIRTUALENV_DIR)/bin/activate; \
	$(VIRTUALENV_DIR)/bin/pip install --upgrade pip; \
	$(VIRTUALENV_DIR)/bin/pip install --cache-dir $(HOME)/.pip-cache -q -r ./requirements.txt;


.PHONY: .validate
.validate:
	@echo
	@echo "==================== validate ===================="
	@echo
	. $(VIRTUALENV_DIR)/bin/activate; \
	for YAML in $(SPEC_YAML_FILES); do \
		echo "Validating $$YAML"; \
		openapi-spec-validator $$YAML || exit 1; \
	done
