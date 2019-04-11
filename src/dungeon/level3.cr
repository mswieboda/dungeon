module Dungeon
  class Level3 < Level
    def load
      @player.x = 150
      @player.y = 150

      [RoomC].each do |room_class|
        @rooms[room_class.name] = room_class.new(@game, @player).as(Room)
      end

      @room = @rooms[RoomC.name].as(Room)

      @room.load
    end

    def start
      message = TypedMessage.new("Level 3")
      @game.show(message)
    end
  end
end
