default: run

build_dungeon:
	crystal build src/dungeon.cr -o build/dungeon

run: build_dungeon
	./build/dungeon
