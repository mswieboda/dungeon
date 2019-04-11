require "./location"

module Dungeon
  class Level
    getter player : Player
    getter? loaded

    @rooms : Hash(String, Room)
    @room : Room

    def initialize(@game : Game)
      @player = Player.new

      @rooms = Hash(String, Room).new
      @room = Room.new(@game, @player)
      @room.load

      @loaded = false
    end

    def load
      # initialize rooms, player location, etc
    end

    def start
      # ran once the level is loaded, and first update and draw ran
    end

    def draw
      @room.draw
    end

    def update
      @room.update

      change_room = @room.change_room
      change_room(**change_room) if change_room

      return if loaded?

      start

      @loaded = true
    end

    def change_room(next_room_name : String, next_door_name : String)
      room = @rooms[next_room_name]
      room.load unless room.loaded?

      door = room.get_door(next_door_name) if room

      if door
        @player.loc = door.new_player_location
        @player.direction = door.opening_direction

        @room = room
      else
        puts "#{self.class.name}#change_room room: #{next_room_name} door: #{next_door_name} not found!"
      end
    end

    def complete?
      false
    end
  end
end
