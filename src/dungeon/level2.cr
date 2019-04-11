module Dungeon
  class Level2 < Level
    def load
      @player.x = 150
      @player.y = 150

      [RoomB, RoomA].each do |room_class|
        @rooms[room_class.name] = room_class.new(@game, @player).as(Room)
      end

      @room = @rooms[RoomB.name].as(Room)

      @room.load
    end

    def start
      message = TypedMessage.new("Level 2")
      @game.show(message)
    end
  end
end
