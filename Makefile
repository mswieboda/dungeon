default: run

build_dungeon:
	env LIBRARY_PATH="$(PWD)/libs" crystal build src/dungeon.cr -o build/dungeon

run: build_dungeon
	env LD_LIBRARY_PATH="$(PWD)/libs" ./build/dungeon
