-include .env

PROJECT_NAME := $(shell basename "$(PWD)")
BINARY := $(PROJECT_NAME)
MOCK_TARGET := test/mock

help: Makefile
	@echo "\n Choose a command run in "$(PROJECT_NAME)":\n"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## all: Install dependencies and build the binary
all: dep test build

## dep: Install dependencies
dep:
	@echo "  >  Install dependencies..."
	@go get github.com/golang/dep/cmd/dep
	@go install github.com/golang/dep/cmd/dep
	@$(GOPATH)/bin/dep ensure

## build: Build the binary
build:
	@echo "  >  Building binary..."
	@go build -o $(BINARY)

## test: Running test
test:
	@echo "  >  Running test..."
	@go test ./config ./app/controller ./app/repository  -coverprofile cover.out

## test-report: Running test and show coverage profile
test-report:
	@-$(MAKE) test
	@go tool cover -html=cover.out

dep-clean:
	@echo "  >  Clean dependencies..."
	@rm -rf vendor

## clean: Clean build files
clean:
	@echo "  >  Clean build files..."
	@rm $(BINARY)
	@-$(MAKE) go-clean

## clean-all: Clean build files and dependency
clean-all: dep-clean clean

## mock: Generate mock class
mock:
	@echo "  >  Generate mock class..."
	@go get github.com/golang/mock/gomock
	@go install github.com/golang/mock/mockgen

	# generate mock for repository
	@for filename in app/repository/*_repository.go; do \
		$(GOPATH)/bin/mockgen -source=$$filename -destination=$(MOCK_TARGET)/$$(basename $$filename) -package=$$(basename $(MOCK_TARGET)); \
	done

.PHONY: help all dep build test test-report dep-clean clean clean-all mock
