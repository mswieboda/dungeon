require "./location"

module Dungeon
  class Camera
    getter width : Int32
    getter height : Int32
    getter x : Int32
    getter y : Int32

    def initialize(@width, @height)
      @x = @y = 0
    end

    def update(player : Player, room_width : Int32, room_height : Int32)
      @x = (player.x - width / 2).clamp(0, room_width - width).to_i
      @y = (player.y - height / 2).clamp(0, room_height - height).to_i
    end
  end
end
