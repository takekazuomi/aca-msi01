KO_DOCKER_REPO	?= acamsiyuhk4mmbl5fmw.azurecr.io
IMAGE_TAG ?= 0.0.1
GO_CMD = ./cmd/msicheck


help:		## show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

publish:	## ko build --push=true ...
	env SOURCE_DATE_EPOCH=$$(git log -1 --format="%ct") \
	KO_DOCKER_REPO=$(KO_DOCKER_REPO) ko build -B -t $(IMAGE_TAG) -t latest $(GO_CMD)

build-local:	## ko build --push=false
	$(MAKE) publish KO_DOCKER_REPO=ko.local

run:		## run remote image
	docker run --rm -it -p 5000:5000 $(KO_DOCKER_REPO)/$(notdir $(GO_CMD)):$(IMAGE_TAG)

run-local:	## run local image
	$(MAKE) run KO_DOCKER_REPO=ko.local

