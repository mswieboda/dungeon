require "./wall"

module Dungeon
  class Door < Wall
    getter? open
    getter? passed_through

    TINT_DEFAULT = LibRay::BROWN

    DOOR_FRAME_WIDTH = 15

    def initialize(loc : Location, width, height, @player : Player, tint = TINT_DEFAULT)
      super(loc, width, height, tint)

      @open = false
      @passed_through = false
    end

    def open
      @open = true
    end

    def close
      @open = false
    end

    def update(_entities)
      return unless open?

      if collision?(@player)
        @passed_through = true
      end
    end

    def draw
      super unless open?

      LibRay.draw_rectangle_v(
        LibRay::Vector2.new(x: x, y: y),
        LibRay::Vector2.new(x: width, y: DOOR_FRAME_WIDTH),
        @tint
      )

      LibRay.draw_rectangle_v(
        LibRay::Vector2.new(x: x, y: y + height - DOOR_FRAME_WIDTH),
        LibRay::Vector2.new(x: width, y: DOOR_FRAME_WIDTH),
        @tint
      )

      draw_collision_box if draw_collision_box?
    end

    def collidable?
      !open?
    end
  end
end
