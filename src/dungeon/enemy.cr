require "./entity"

module Dungeon
  class Enemy < Entity
    include DirectionTextures

    property tint : LibRay::Color

    TINT_DEFAULT = LibRay::ORANGE

    PLAYER_HIT_FLASH_TIME     = 15
    PLAYER_HIT_FLASH_INTERVAL =  5
    PLAYER_HIT_FLASH_TINT     = LibRay::RED

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @tint = TINT_DEFAULT

      @player_hit_flash_time = 0
      @invincible = false
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
    end

    def movement(collision_rects)
      if @player_hit_flash_time >= PLAYER_HIT_FLASH_TIME
        @player_hit_flash_time = 0
        @tint = TINT_DEFAULT
        @invincible = false
      elsif @player_hit_flash_time > 0
        @tint = (@player_hit_flash_time / PLAYER_HIT_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : PLAYER_HIT_FLASH_TINT
        @player_hit_flash_time += 1
      end
    end

    def invincible?
      @invincible
    end

    def hit
      return if invincible?
      @invincible = true
      @player_hit_flash_time = 1
    end
  end
end
