require "./entity"

module Dungeon
  class Enemy < Entity
    include DirectionTextures

    MOVEMENT = 50

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
          x: loc.x - width / 2,
          y: loc.y - height / 2
        ),
        tint: LibRay::RED
      )

      draw_collision_box if draw_collision_box?
    end

    def movement(collision_rects)
    end
  end
end
