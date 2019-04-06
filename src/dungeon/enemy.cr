require "./living_entity"

module Dungeon
  class Enemy < LivingEntity
    @animation : Animation

    @path_delta : Hash(Symbol, Int32)
    @path_end_x : Float32
    @path_end_y : Float32

    TINT_DEFAULT = LibRay::ORANGE

    MOVEMENT_X = 100
    MOVEMENT_Y = 100

    MOVE_WITH_PATH = true

    BUMP_DAMAGE = 5

    def initialize(loc : Location, collision_box : Box)
      @direction = Direction::Up

      @animation = Animation.new(sprite: Sprite.get("player"))

      width = @animation.width
      height = @animation.height

      super(loc, width, height, collision_box, TINT_DEFAULT)

      @animation.tint = @tint
      @animation.row = @direction.value

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
      ]
      @path_delta = @path_deltas[0]
      @path_end_x = x
      @path_end_x += @path_delta[:dx] if @path_delta.has_key?(:dx)
      @path_end_y = y
      @path_end_y += @path_delta[:dy] if @path_delta.has_key?(:dy)
    end

    def tint!(tint : LibRay::Color)
      @tint = tint
      @animation.tint = tint
    end

    def draw
      @animation.draw(x, y)

      draw_collision_box if draw_collision_box?
      draw_hit_points if draw_hit_points?
    end

    def update(entities)
      super(entities)

      movement(entities)
    end

    def movement(entities)
      if @path_deltas.any? && MOVE_WITH_PATH
        player = entities.find(&.is_a?(Player))
        player = player.as(Player) if player

        delta_t = LibRay.get_frame_time
        delta_x = delta_y = 0_f32

        delta_x = delta_t * MOVEMENT_X * @path_delta[:dx] / @path_delta[:dx].abs if @path_delta.has_key?(:dx)
        delta_y = delta_t * MOVEMENT_Y * @path_delta[:dy] / @path_delta[:dy].abs if @path_delta.has_key?(:dy)

        @loc.x += delta_x
        @loc.y += delta_y

        if collisions?(entities)
          player_bump_detection(player) if player

          @loc.x -= delta_x
          @loc.y -= delta_y

          new_path
        else
          new_path if path_ended?(delta_x, delta_y)
        end
      end
    end

    def new_path
      @path_index = rand(@path_deltas.size)

      @path_delta = @path_deltas[@path_index]
      @path_end_x = x
      @path_end_x += @path_delta[:dx] if @path_delta.has_key?(:dx)
      @path_end_y = y
      @path_end_y += @path_delta[:dy] if @path_delta.has_key?(:dy)

      if @path_delta.has_key?(:dx)
        if @path_delta.has_key?(:dy)
          if @path_delta[:dx].abs > @path_delta[:dy].abs
            direction_x!(@path_delta[:dx])
          elsif @path_delta[:dy].abs > @path_delta[:dx].abs
            direction_y!(@path_delta[:dy])
          end
        else
          direction_x!(@path_delta[:dx])
        end
      else
        direction_y!(@path_delta[:dy])
      end
    end

    def path_ended?(delta_x, delta_y)
      reached_x = false
      reached_y = false

      if delta_x > 0 && x >= @path_end_x
        reached_x = true
      elsif delta_x < 0 && x <= @path_end_x
        reached_x = true
      elsif delta_x == 0 && x == @path_end_x
        reached_x = true
      end

      return false unless reached_x

      if delta_y > 0 && y >= @path_end_y
        reached_y = true
      elsif delta_y < 0 && y <= @path_end_y
        reached_y = true
      elsif delta_y == 0 && y == @path_end_y
        reached_y = true
      end

      reached_y
    end

    def direction_x!(delta_x)
      if delta_x > 0
        @direction = Direction::Right
        @animation.row = @direction.value
      elsif delta_x < 0
        @direction = Direction::Left
        @animation.row = @direction.value
      end
    end

    def direction_y!(delta_y)
      if delta_y > 0
        @direction = Direction::Down
        @animation.row = @direction.value
      elsif delta_y < 0
        @direction = Direction::Up
        @animation.row = @direction.value
      end
    end

    def bump_damage
      BUMP_DAMAGE
    end

    def player_bump_detection(player : Player)
      if !invincible? && collision?(player)
        player.enemy_bump(bump_damage)
      end
    end

    def invincible?
      @hit_flash_timer > 0 || @death_timer > 0
    end

    def collidable?
      true
    end
  end
end
