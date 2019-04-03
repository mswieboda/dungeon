require "./entity"

module Dungeon
  class Enemy < Entity
    include DirectionTextures

    getter? dead

    @path_delta : Hash(Symbol, Int32)
    @path_end_x : Float32
    @path_end_y : Float32

    TINT_DEFAULT = LibRay::ORANGE

    HIT_FLASH_TIME     = 15
    HIT_FLASH_INTERVAL =  5
    HIT_FLASH_TINT     = LibRay::RED

    DEATH_TIME = 15

    MAX_HIT_POINTS  = 15
    DRAW_HIT_POINTS = true

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

      super(loc, width, height, collision_box)

      @tint = TINT_DEFAULT

      @hit_flash_timer = 0

      @hit_points = MAX_HIT_POINTS
      @death_timer = 0
      @dead = false

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
      draw_hit_points if DRAW_HIT_POINTS
    end

    def draw_hit_points
      color = LibRay::GREEN

      red = 0
      green = 255
      blue = 0
      alpha = 255

      # green -> yellow -> red
      if @hit_points >= MAX_HIT_POINTS / 2
        red = (255 * MAX_HIT_POINTS / @hit_points) - 255
        green = 255
      elsif @hit_points < MAX_HIT_POINTS / 2
        red = 255
        green = 255 * @hit_points / MAX_HIT_POINTS * 2
      end

      color = LibRay::Color.new(r: red, g: green, b: blue, a: alpha)

      LibRay.draw_text(
        text: @hit_points.to_s,
        pos_x: x,
        pos_y: y - height / 1.5,
        font_size: 20,
        color: color
      )
    end

    def update(entities)
      hit_flash
      death_fade

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

    def hit_flash
      if @hit_flash_timer >= HIT_FLASH_TIME
        @hit_flash_timer = 0
        @tint = TINT_DEFAULT
      elsif @hit_flash_timer > 0
        @tint = (@hit_flash_timer / HIT_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : HIT_FLASH_TINT
        @hit_flash_timer += 1
      end
    end

    def death_fade
      if @death_timer >= DEATH_TIME
        @death_timer = 0
        @dead = true
      elsif @death_timer > 0
        @tint = TINT_DEFAULT
        @tint.a = 255 - 255 * @death_timer / DEATH_TIME
        @death_timer += 1
      end
    end

    def player_bump_detection(player : Player)
      if !invincible? && collision?(player)
        player.enemy_bump(bump_damage)
      end
    end

    def bump_damage
      BUMP_DAMAGE
    end

    def invincible?
      @hit_flash_timer > 0 || @death_timer > 0
    end

    def die
      @hit_points = 0
      @death_timer = 1
    end

    def hit(damage = 0)
      return if invincible?

      @hit_flash_timer = 1
      @hit_points -= damage

      die if @hit_points <= 0
    end

    def removed?
      dead?
    end
  end
end
