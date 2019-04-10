require "./wall"

module Dungeon
  class Door < Wall
    getter name : String
    getter? open
    getter? passed_through
    getter opening_direction

    TINT_DEFAULT = LibRay::BROWN

    DOOR_FRAME_WIDTH = 15

    WIDTH = 128
    DEPTH =  32

    def initialize(loc : Location, @player : Player, @name : String, @opening_direction : Direction, @next_room_name : String, @next_door_name : String, tint = TINT_DEFAULT)
      width = height = 0

      case opening_direction
      when .up?, .down?
        width = WIDTH
        height = DEPTH
      when .left?, .right?
        width = 32
        height = 128
      end

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

    def pass_through
      @passed_through = false

      {
        next_room_name: @next_room_name,
        next_door_name: @next_door_name,
      }
    end

    def new_player_location
      offset_x = offset_y = 0

      case opening_direction
      when .up?
        offset_y = height - @player.origin.y + @player.collision_box.height / 2
        offset_x = origin.x - @player.origin.x
      when .down?
        offset_y = -@player.origin.y - @player.collision_box.height / 2
        offset_x = origin.x - @player.origin.x
      when .left?
        offset_x = width - @player.origin.x + @player.collision_box.width / 2
        offset_y = origin.y - @player.origin.y
      when .right?
        offset_x = -@player.origin.x - @player.collision_box.width / 2
        offset_y = origin.y - @player.origin.y
      end

      # centered in door
      Location.new(
        x: x + offset_x,
        y: y + offset_y
      )
    end

    def update(_entities)
      return unless open?

      if collision?(@player)
        @passed_through = true
      end
    end

    def draw
      super unless open?

      case opening_direction
      when .up?, .down?
        LibRay.draw_rectangle_v(
          LibRay::Vector2.new(x: x, y: y),
          LibRay::Vector2.new(x: DOOR_FRAME_WIDTH, y: height),
          @tint
        )

        LibRay.draw_rectangle_v(
          LibRay::Vector2.new(x: x + width - DOOR_FRAME_WIDTH, y: y),
          LibRay::Vector2.new(x: DOOR_FRAME_WIDTH, y: height),
          @tint
        )
      when .left?, .right?
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
      end

      draw_collision_box if draw_collision_box?
    end

    def collidable?
      !open?
    end
  end
end
