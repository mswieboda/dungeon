require "./location"

module Dungeon
  class Level
    getter player : Player
    getter? loaded

    @rooms : Hash(String, Room)
    @room : Room

    def initialize(@game : Game)
      @player = Player.new(loc: Location.new(150, 150))

      @rooms = Hash(String, Room).new

      rooms = [] of Room

      [RoomA, RoomC, RoomB].each do |room_class|
        rooms << room_class.new(@game, @player).as(Room)
      end

      @room = rooms.last.as(Room)

      rooms.each do |room|
        @rooms[room.class.name] = room
      end

      rooms.clear

      @room.load_initial

      @loaded = false
    end

    def start
      message = TypedMessage.new("Welcome to Dungeon.\nIf this is your first time in Dungeon, you have to fight...")
      @game.show(message)
    end

    def draw
      @room.draw
    end

    def update
      @room.update

      room_change = @room.room_change
      room_change(**room_change) if room_change

      return if loaded?

      start

      @loaded = true
    end

    def room_change(next_room_name : String, next_door_name : String)
      room = @rooms[next_room_name]
      room.load_initial unless room.loaded?

      door = room.get_door(next_door_name) if room

      if door
        @player.loc = door.new_player_location
        @player.direction = door.opening_direction

        @room = room
      else
        puts "#{self.class.name}#room_change room: #{next_room_name} door: #{next_door_name} not found!"
      end
    end

    def complete?
      false
    end
  end
end
