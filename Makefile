default: build_and_run

build_dungeon:
	env LIBRARY_PATH="$(PWD)/lib_ext" crystal build src/dungeon.cr -o build/dungeon

build_and_run: build_dungeon run

run:
	env LD_LIBRARY_PATH="$(PWD)/lib_ext" ./build/dungeon
