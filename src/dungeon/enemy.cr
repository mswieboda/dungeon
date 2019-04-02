require "./entity"

module Dungeon
  class Enemy < Entity
    include DirectionTextures

    getter tint : LibRay::Color
    getter? dead

    TINT_DEFAULT = LibRay::ORANGE

    PLAYER_HIT_FLASH_TIME     = 15
    PLAYER_HIT_FLASH_INTERVAL =  5
    PLAYER_HIT_FLASH_TINT     = LibRay::RED

    DEATH_TIME = 15

    MAX_HIT_POINTS  = 15
    DRAW_HIT_POINTS = true

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @tint = TINT_DEFAULT

      @hit_points = MAX_HIT_POINTS
      @player_hit_flash_time = 0
      @invincible = false

      @death_timer = 0
      @dead = false
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

    def update(_entities)
      if @player_hit_flash_time >= PLAYER_HIT_FLASH_TIME
        @player_hit_flash_time = 0
        @tint = TINT_DEFAULT
        @invincible = false
      elsif @player_hit_flash_time > 0
        @tint = (@player_hit_flash_time / PLAYER_HIT_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : PLAYER_HIT_FLASH_TINT
        @player_hit_flash_time += 1
      end

      if @death_timer >= DEATH_TIME
        @death_timer = 0
        @dead = true
      elsif @death_timer > 0
        @tint = TINT_DEFAULT
        @tint.a = 255 - 255 * @death_timer / DEATH_TIME
        @death_timer += 1
      end
    end

    def invincible?
      @invincible
    end

    def die
      @invincible = true
      @hit_points = 0
      @death_timer = 1
    end

    def hit(damage = 0)
      return if invincible?

      @invincible = true
      @player_hit_flash_time = 1
      @hit_points -= damage

      die if @hit_points <= 0
    end

    def removed?
      dead?
    end
  end
end
