.PHONY: build clean run test install

BINARY_NAME=upgrade_notify

build:
	go build -ldflags="-s -w" -o bin/$(BINARY_NAME) .

run: build./bin/$(BINARY_NAME)

test:
	go test -v ./...

clean:
	rm -rf bin/*

install: build
	install -Dm755 bin/$(BINARY_NAME)
