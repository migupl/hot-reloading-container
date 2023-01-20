.PHONY = clean start stop shell

IMAGE_NAME := where-picture-taken

ENVIRONMENT := development

# Shell to use for running scripts
SHELL := $(shell which bash)

# Get OS
OSTYPE := $(shell uname)

# In case you are using docker for Mac, hardcode some values.
# Docker will sync file to whichever user is created on the container
# https://stackoverflow.com/questions/43097341/docker-on-macosx-does-not-translate-file-ownership-correctly-in-volumes
ifeq ($(OSTYPE), Darwin)
  UID := 1000
else
# Get the uid/gid for the user running make, this is the default case for Linux/Unix machines.
  UID := $(shell id -u)
endif

# Get podman path or an empty string
PODMAN := $(shell command -v podman)
PODMAN_NETWORK := cni-scaffold-eth

# Get docker path or an empty string
DOCKER := $(shell command -v docker)

# About container
CONTAINER_CMD := $(if $(PODMAN),$(PODMAN),$(DOCKER))
ifeq ($(PODMAN),$(CONTAINER_CMD))
	PODMAN_ARGS := --net $(PODMAN_NETWORK)
endif

# Get git path or an empty string
GIT := $(shell command -v git)

# Get container image or an empty string
CONTAINER_IMAGE := $(shell $(CONTAINER_CMD) ps --all --filter name=$(IMAGE_NAME) -q)

# Test if the dependencies we need to run this Makefile are installed
deps:
ifndef CONTAINER_CMD
	@echo "Neither Docker nor Podman are not available. Please install any of them"
	@exit 1
endif
ifndef GIT
	@echo "Git is not available. Please install Git"
	@exit 1
endif

# Remove any local image
clean: deps
	[ -z "$(CONTAINER_IMAGE)" ] || $(CONTAINER_CMD) rm -f $(IMAGE_NAME)

# Sets the stack up and that's it 
start: deps create-network
	[ -z "$(CONTAINER_IMAGE)" ] && $(CONTAINER_CMD) run \
		--name $(IMAGE_NAME) \
		$(PODMAN_ARGS) \
		-v `pwd`:/usr/src/app \
		-w /usr/src/app \
		-p 8000:8080 \
		-dt node:19-alpine || $(CONTAINER_CMD) restart $(IMAGE_NAME)

	# Install all dependencies
	$(CONTAINER_CMD) exec -ti $(IMAGE_NAME) ash -c "npm install -g live-server"
	# Launch the app on hot reloading mode
	$(CONTAINER_CMD) exec -dt $(IMAGE_NAME) ash -c "live-server"

# Stop the container
stop: deps
	[ -z "$(CONTAINER_IMAGE)" ] || $(CONTAINER_CMD) stop $(IMAGE_NAME)

# Run a shell into the development container image
shell: deps
	$(CONTAINER_CMD) exec -ti $(IMAGE_NAME) ash

# Create the network for podman rootless
# Basic Networking Guide for Podman
# https://github.com/containers/podman/blob/main/docs/tutorials/basic_networking.md
create-network: deps
	[ -z "$(PODMAN)" ] || ( \
		$(PODMAN) network exists $(PODMAN_NETWORK) || \
		$(PODMAN) network create $(PODMAN_NETWORK) \
	)

# Remove the created network for podman
remove-network: deps
	[ -z "$(PODMAN)" ] || ( \
		$(PODMAN) network exists $(PODMAN_NETWORK) && \
		$(PODMAN) network remove $(PODMAN_NETWORK) \
	)
