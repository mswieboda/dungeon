require "./location"

module Dungeon
  @rooms : Array(Room)
  @room : Room

  class Level
    def initialize(@player : Player, screenWidth : Int32, screenHeight : Int32)
      @rooms = [] of Room

      @room = RoomA.new(@player, screenWidth, screenHeight).as(Room)

      @rooms << @room
      @rooms << RoomB.new(@player, screenWidth, screenHeight)
    end

    def draw
      @room.draw
    end

    def update
      @room.update

      @room = @rooms[0].as(Room) if LibRay.key_pressed?(LibRay::KEY_ONE)
      @room = @rooms[1].as(Room) if LibRay.key_pressed?(LibRay::KEY_TWO)
    end

    def complete?
      @room.left_room?
    end
  end
end
