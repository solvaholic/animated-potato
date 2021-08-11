#!/usr/bin/make -f

SHELL = /bin/bash
SRCDIR = ${PWD}
NAME = railsbox
IMAGE ?= solvaholic/${NAME}
IMAGE_VER ?= local
IMAGE_TAG ?= ${IMAGE}:${IMAGE_VER}
LINTER_TAG ?= github/super-linter

# Set $_U to override the image's default user, for example:
# 	make container-shell _U=root
PNAME = --name ${NAME}
PUSER = $(if ${_U},--user ${_U},)

# Recipes
default: lint

lint: lint-super-linter
build: lint-dockerfile docker-build
shell: container-shell

lint-dockerfile:
	@echo "Linting Dockerfile..."
	@docker run --rm --pull always \
		-e IGNORE_GITIGNORED_FILES=true \
		-e VALIDATE_ENV=false \
		-e RUN_LOCAL=true \
		--entrypoint /usr/bin/hadolint \
		--volume "$(realpath ${SRCDIR})":"/tmp/lint":ro \
		${LINTER_TAG} /tmp/lint/Dockerfile
	@echo "Dockerfile linted!"

lint-super-linter:
	@echo "Linting all the things..."
	@docker run --rm --pull always \
		-e IGNORE_GITIGNORED_FILES=true \
		-e VALIDATE_ENV=false \
		-e RUN_LOCAL=true \
		--volume "$(realpath ${SRCDIR})":"/tmp/lint":ro \
		${LINTER_TAG}
	@echo "All the things linted!"

docker-build:
	@echo "Building ${IMAGE_TAG} image..."
	@docker build \
		--build-arg image_version="${IMAGE_VER}" \
		--tag ${IMAGE_TAG} ${SRCDIR}
	@echo "${IMAGE_TAG} image built!"
	@docker images ${IMAGE_TAG}

container-shell:
	@echo "Running interactive ${NAME} shell..."
	@docker start ${NAME} 2>/dev/null || \
		docker run --tty --detach ${PNAME} ${PUSER} \
			--volume "$(realpath ${SRCDIR})":/code:rw \
			--publish 3000:3000 \
			${IMAGE_TAG}
	@docker exec --tty --interactive ${PUSER} ${NAME} ${SHELL}
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