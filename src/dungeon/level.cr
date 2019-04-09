require "./location"

module Dungeon
  @room : Room

  class Level
    def initialize(@player : Player, screenWidth : Int32, screenHeight : Int32)
      @room = Room.new(@player, screenWidth, screenHeight)
    end

    def draw
      @room.draw
    end

    def update
      @room.update
    end

    def complete?
      @room.left_room?
    end
  end
end
