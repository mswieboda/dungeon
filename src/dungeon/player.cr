require "./entity"

module Dungeon
  class Player < Entity
    include DirectionTextures

    PLAYER_MOVEMENT = 200

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures
    end

    def texture_file_name
      "player"
    end

    def draw
      LibRay.draw_texture_v(
        texture: direction_textures[direction.value],
        position: LibRay::Vector2.new(
          x: x - width / 2,
          y: y - height / 2
        ),
        tint: LibRay::WHITE
      )

      draw_collision_box if draw_collision_box?
    end

    def movement(collision_rects)
      delta_t = LibRay.get_frame_time
      delta = delta_t * PLAYER_MOVEMENT

      # movement
      if LibRay.key_down?(LibRay::KEY_W)
        @direction = Direction::Up
        @loc.y -= delta
        @loc.y += delta if collisions?(collision_rects)
      end

      if LibRay.key_down?(LibRay::KEY_A)
        @direction = Direction::Left
        @loc.x -= delta
        @loc.x += delta if collisions?(collision_rects)
      end

      if LibRay.key_down?(LibRay::KEY_S)
        @direction = Direction::Down
        @loc.y += delta
        @loc.y -= delta if collisions?(collision_rects)
      end

      if LibRay.key_down?(LibRay::KEY_D)
        @direction = Direction::Right
        @loc.x += delta
        @loc.x -= delta if collisions?(collision_rects)
      end
    end
  end
end
