.PHONY: all build test clean

all: build

build:
	ponyc -p src -o build src

clean:
	rm -rf build

test:
	ponyc -p src --debug -o build src
	./build/src