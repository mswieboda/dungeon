require "./moving_enemy"

module Dungeon
  class SoldierMoving < MovingEnemy
    @path_delta : Hash(Symbol, Int32)
    @path_end_x : Float32
    @path_end_y : Float32

    MOVEMENT = 100

    def initialize(loc : Location)
      sprite = Sprite.get("player")
      tint = LibRay::ORANGE

      collision_box = Box.new(
        loc: Location.new(-12, 16),
        width: 24,
        height: 16
      )

      super(loc, sprite, collision_box, tint)

      @path_index = 0
      @path_deltas = [
        {:dx => 20},
        {:dy => 30},
        {:dx => -20, :dy => 50},
        {:dy => -30},
        {:dy => 50},
        {:dx => 20, :dy => 30},
        {:dx => 50, :dy => 10},
        {:dx => 50},
        {:dx => 30, :dy => -50},
        {:dy => -10},
        {:dx => -30, :dy => -20},
        {:dx => -50, :dy => -50},
        {:dx => 50, :dy => 50},
        {:dx => 10, :dy => 10},
        {:dx => 5, :dy => -5},
        {:dx => -30, :dy => -15},
        {:dx => -30, :dy => 30},
        {:dx => -20, :dy => 20},
      ]
      @path_delta = @path_deltas[0]
      @path_end_x = x
      @path_end_x += @path_delta[:dx] if @path_delta.has_key?(:dx)
      @path_end_y = y
      @path_end_y += @path_delta[:dy] if @path_delta.has_key?(:dy)
    end

    def moving?
      !@death_timer.active? && !dead? && @path_deltas.any?
    end

    def move_delta(delta_t)
      delta_x = delta_y = 0_f32

      delta_x = delta_t * MOVEMENT * @path_delta[:dx] / @path_delta[:dx].abs if @path_delta.has_key?(:dx)
      delta_y = delta_t * MOVEMENT * @path_delta[:dy] / @path_delta[:dy].abs if @path_delta.has_key?(:dy)

      {x: delta_x, y: delta_y}
    end

    def set_direction
      if @path_delta.has_key?(:dx)
        if @path_delta.has_key?(:dy)
          if @path_delta[:dx].abs > @path_delta[:dy].abs
            set_direction_x(@path_delta[:dx])
          elsif @path_delta[:dy].abs > @path_delta[:dx].abs
            set_direction_y(@path_delta[:dy])
          else
            # dx and dy are the same
            # for now set direction to y
            set_direction_y(@path_delta[:dy])
          end
        else
          set_direction_x(@path_delta[:dx])
        end
      else
        set_direction_y(@path_delta[:dy])
      end

      @animation.row = @direction.value
    end

    def move_again?(delta : NamedTuple(x: Float32, y: Float32))
      reached_x = false
      reached_y = false

      if delta[:x] > 0 && x >= @path_end_x
        reached_x = true
      elsif delta[:x] < 0 && x <= @path_end_x
        reached_x = true
      elsif delta[:x] == 0 && x == @path_end_x
        reached_x = true
      end

      return false unless reached_x

      if delta[:y] > 0 && y >= @path_end_y
        reached_y = true
      elsif delta[:y] < 0 && y <= @path_end_y
        reached_y = true
      elsif delta[:y] == 0 && y == @path_end_y
        reached_y = true
      end

      reached_y
    end

    def move_again
      @path_index = rand(@path_deltas.size)

      @path_delta = @path_deltas[@path_index]
      @path_end_x = x
      @path_end_x += @path_delta[:dx] if @path_delta.has_key?(:dx)
      @path_end_y = y
      @path_end_y += @path_delta[:dy] if @path_delta.has_key?(:dy)
    end
  end
end
