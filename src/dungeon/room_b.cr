require "./location"

module Dungeon
  class RoomB < Room
    def initialize(player)
      width = Game::SCREEN_WIDTH
      height = Game::SCREEN_HEIGHT

      super(player, width, height)
    end

    def load_initial
      # player
      @entities << @player

      # TODO: move player to start location, change direction, etc

      door_height = 128
      door_width = 32

      # walls
      # @entities << Wall.new(loc: Location.new(0, 0), width: width, height: 32)

      door = Door.new(
        loc: Location.new(width / 2, 0),
        player: @player,
        opening_direction: Direction::Up,
        name: "north",
        next_room_name: RoomB.name,
        next_door_name: "south"
      )
      @doors << door
      @entities << door

      @entities << Wall.new(loc: Location.new(width - 32, 0), width: 32, height: height)

      # @entities << Wall.new(loc: Location.new(0, height - 32), width: width, height: 32)

      door = Door.new(
        loc: Location.new(width / 2, height - Door::DEPTH),
        player: @player,
        opening_direction: Direction::Down,
        name: "south",
        next_room_name: RoomB.name,
        next_door_name: "north"
      )
      @doors << door
      @entities << door

      @entities << Wall.new(loc: Location.new(0, 0), width: 32, height: height / 4 - door_height)

      door = Door.new(
        loc: Location.new(0, height / 4 - door_height),
        player: @player,
        opening_direction: Direction::Left,
        name: "east",
        next_room_name: RoomA.name,
        next_door_name: "west"
      )
      @doors << door
      @entities << door

      @entities << Wall.new(loc: Location.new(0, height / 4), width: 32, height: height / 8)

      door = Door.new(
        loc: Location.new(0, height / 4 + height / 8),
        player: @player,
        name: "east2",
        opening_direction: Direction::Left,
        next_room_name: RoomB.name,
        next_door_name: "east"
      )
      @doors << door
      @entities << door

      @entities << Wall.new(loc: Location.new(0, height / 4 + height / 8 + door_height), width: 32, height: height / 2 - door_height / 2)

      # items
      @entities << Chest.new(loc: Location.new(700, 300), room: self, player: @player)
      @entities << LockedChest.new(loc: Location.new(800, 375), room: self, player: @player)

      # enemies
      @entities << BasicEnemy.new(loc: Location.new(100, 100))

      # message
      message = Message.new("Welcome to Dungeon.\nIf this is your first time in Dungeon, you have to fight...")
      message.open
      @messages << message

      super
    end
  end
end
