MAKEFLAGS += --no-print-directory
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
HOSTGO := env -u GOOS -u GOARCH -u GOARM -- go
LDFLAGS := $(LDFLAGS)

VERSION ?= latest
PROJECT ?= gostress
REPOSITORY ?= quay.io/caspell
IMAGE_LINK = $(REPOSITORY)/$(PROJECT):$(VERSION)

# Go built-in race detector works only for 64 bits architectures.
ifneq ($(GOARCH), 386)
	race_detector := -race
endif

default: build

.PHONY: run
run: 
	build/$(PROJECT)

.PHONY: env
env:
	@echo "" $(VERSION)
	@echo "" $(PROJECT)
	@echo "" $(REPOSITORY)
	@echo "" $(IMAGE_LINK)

.PHONY: clean
clean: env
	rm -rf build/*

.PHONY: build
build: clean 
	go build -o build/$(PROJECT) -ldflags "-w -s $(LDFLAGS)" main.go

.PHONY: strip
strip: build
	strip build/$(PROJECT)

.PHONY: minimize
minimize: strip
	upx --best --lzma build/$(PROJECT)


.PHONY: docker-clean
docker-clean: 
	docker rmi $(IMAGE_LINK)
	
.PHONY: docker-build
docker-build: minimize 
	docker build -f Dockerfile -t $(IMAGE_LINK) .

.PHONY: docker-push
docker-push: docker-build
	docker push $(IMAGE_LINK)
