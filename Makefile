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

# Run all targets
.PHONY: all
all: validate

.PHONY: clean
clean: .clean-npm

.PHONY: validate
validate: .install .validate

.PHONY: build
build: .install .build

.PHONY: gh-pages
gh-pages: .install .gh-pages

# list all makefile targets
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.PHONY: .clean-npm
.clean-npm:
	@echo "==================== clean node_modules/ web_modules/ ===================="
	rm -rf $(ROOT_DIR)/node_modules
	rm -rf $(ROOT_DIR)/web_modules

.PHONY: .install
.install:
	@echo
	@echo "==================== install ===================="
	@echo
	npm install

.PHONY: .validate
.validate:
	@echo
	@echo "==================== validate ===================="
	@echo
	npm test

.PHONY: .build
.build:
	@echo
	@echo "==================== build ===================="
	@echo
	npm run build

.PHONY: .gh-pages
.gh-pages:
	@echo
	@echo "==================== gh-pages ===================="
	@echo
	npm run gh-pages
