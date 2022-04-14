IMAGE_NAME	?= msicheck
IMAGE_TAG	?= latest

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

push: build
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

run:
	docker run --rm -it -p 5000:5000 $(IMAGE_NAME):$(IMAGE_TAG)
