default: run

build:
	crystal build src/dungeon.cr

run: build
	./dungeon
