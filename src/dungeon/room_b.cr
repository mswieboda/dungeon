require "./location"

module Dungeon
  class RoomB < Room
    def load_initial
      # player
      @entities << @player

      # TODO: move player to start location, change direction, etc

      # walls
      @entities << Wall.new(loc: Location.new(0, 0), width: width, height: 32)

      door_height = 128

      @entities << Wall.new(loc: Location.new(width - 32, 0), width: 32, height: height / 4 - door_height)

      @door = Door.new(loc: Location.new(width - 32, height / 4 - door_height), width: 32, height: door_height, player: @player)
      @entities << @door

      @entities << Wall.new(loc: Location.new(width - 32, height / 4), width: 32, height: height - height / 4)

      @entities << Wall.new(loc: Location.new(0, height - 32), width: width, height: 32)
      @entities << Wall.new(loc: Location.new(0, 0), width: 32, height: height)
      @entities << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # items
      @entities << Chest.new(loc: Location.new(700, 300), room: self, player: @player)
      @entities << LockedChest.new(loc: Location.new(800, 375), room: self, player: @player)

      # enemies
      @entities << BasicEnemy.new(loc: Location.new(100, 100))
    end
  end
end
