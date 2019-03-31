default: run

build:
	crystal build src/dungeon.cr -o build/dungeon

run: build
	./build/dungeon
