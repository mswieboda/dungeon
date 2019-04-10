require "./location"

module Dungeon
  @rooms : Hash(String, Room)
  @room : Room

  class Level
    def initialize(@player : Player, screenWidth : Int32, screenHeight : Int32)
      @rooms = Hash(String, Room).new

      rooms = [] of Room

      [RoomA, RoomB, RoomC].each do |room_class|
        rooms << room_class.new(@player).as(Room)
      end

      @room = rooms.last.as(Room)

      rooms.each do |room|
        @rooms[room.class.name] = room
      end

      rooms.clear

      @room.load_initial
    end

    def draw
      @room.draw
    end

    def update
      @room.update

      room_change = @room.room_change
      room_change(**room_change) if room_change
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
