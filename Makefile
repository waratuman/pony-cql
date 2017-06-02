.PHONY: all build test clean

all: build

build:
	stable env ponyc -p src -o build src

clean:
	rm -rf build

test:
	stable env ponyc -p src --debug -o build src
	./build/src