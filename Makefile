#!/usr/bin/make -f

SHELL = /bin/bash
SRCDIR = ${PWD}
NAME = railsbox
IMAGE ?= solvaholic/${NAME}
IMAGE_VER ?= local
IMAGE_TAG ?= ${IMAGE}:${IMAGE_VER}

# Set $_U to override the image's default user, for example:
# 	make container-shell _U=root
PNAME = --name ${NAME}
PUSER = $(if ${_U},--user ${_U},)

# Recipes
default: lint

lint: lint-super-linter
build: lint-dockerfile-lint docker-build
shell: container-shell

lint-dockerfile-lint:
	# TODO: Use linter in super-linter
	@echo "Container image policies skipped!"

lint-super-linter:
	@echo "Linting all the things..."
	@docker run --rm \
		-e VALIDATE_ENV=false \
		-e RUN_LOCAL=true \
		-v "$(realpath ${SRCDIR})":"/tmp/lint":ro \
		github/super-linter
	@echo "All the things linted!"

docker-build:
	@echo "Building ${IMAGE_TAG} image..."
	@docker build \
		--build-arg image_version="${IMAGE_VER}" \
		-t ${IMAGE_TAG} ${SRCDIR}
	@echo "${IMAGE_TAG} image built!"
	@docker images ${IMAGE_TAG}

container-shell:
	@echo "Running interactive ${NAME} shell..."
	@docker exec -it ${PUSER} ${NAME} ${SHELL} 2>/dev/null || \
		docker run -it --rm ${PNAME} ${PUSER} \
			-v "$(realpath ${SRCDIR})":/code:rw \
			${IMAGE_TAG}
	@echo "Interactive ${NAME} shell finished!"

inspect-labels:
	@echo "Inspecting image labels..."
	@docker inspect --format \
		" Image Source: {{ index .Config.Labels \"org.opencontainers.image.source\" }}" ${IMAGE_TAG}
	@docker inspect --format \
		" Name: {{ index .Config.Labels \"name\" }}" ${IMAGE_TAG}
	@docker inspect --format \
		" Version: {{ index .Config.Labels \"version\" }}" ${IMAGE_TAG}
	@docker inspect --format \
		" Maintainer: {{ index .Config.Labels \"maintainer\" }}" ${IMAGE_TAG}
	@echo "Image labels inspected!"