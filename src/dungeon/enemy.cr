require "./living_entity"

module Dungeon
  class Enemy < LivingEntity
    include DirectionTextures

    @path_delta : Hash(Symbol, Int32)
    @path_end_x : Float32
    @path_end_y : Float32

    TINT_DEFAULT = LibRay::ORANGE

    MOVEMENT_X = 100
    MOVEMENT_Y = 100

    MOVE_WITH_PATH = false

    BUMP_DAMAGE = 5

    def initialize(loc : Location, collision_box : Box)
      # TODO: switch this to sprite sheet
      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      width = @direction_textures[@direction.value].width
      height = @direction_textures[@direction.value].height

      super(loc, width, height, collision_box, TINT_DEFAULT)

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

    def texture_file_name
      "player"
    end

    def draw
      LibRay.draw_texture_v(
        texture: direction_textures[direction.value],
        position: LibRay::Vector2.new(
          x: loc.x - width / 2,
          y: loc.y - height / 2
        ),
        tint: @tint
      )

      draw_collision_box if draw_collision_box?
      draw_hit_points if draw_hit_points?
    end

    def update(entities)
      super

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

    def removed?
      dead?
    end
  end
end
