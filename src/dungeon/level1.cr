module Dungeon
  class Level1 < Level
    def load
      @player.x = 150
      @player.y = 150

      [RoomB, RoomA, RoomC].each do |room_class|
        @rooms[room_class.name] = room_class.new(@game, @player).as(Room)
      end

      @room = @rooms[RoomB.name].as(Room)

      @room.load
    end

    def start
      message = TypedMessage.new("Welcome to Dungeon.\nIf this is your first time in Dungeon, you have to fight...")
      @game.show(message)
    end
  end
end
