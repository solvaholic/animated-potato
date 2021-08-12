#!/usr/bin/make -f

SHELL = /bin/bash
SRCDIR = ${PWD}
LINTER_TAG ?= github/super-linter

# Recipes
default: lint

lint: lint-super-linter

lint-super-linter:
	@echo "Linting all the things..."
	@docker run --rm --pull always \
		-e IGNORE_GITIGNORED_FILES=true \
		-e VALIDATE_ENV=false \
		-e RUN_LOCAL=true \
		--volume "$(realpath ${SRCDIR})":"/tmp/lint":ro \
		${LINTER_TAG}
	@echo "All the things linted!"
