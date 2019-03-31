require "./entity"

class Enemy < Entity
  include DirectionTextures

  MOVEMENT = 50

  def initialize(@loc : Location, @width : Float32, @height : Float32)
    super(@loc, @width, @height)

    @direction = Direction::Up
    @direction_textures = [] of LibRay::Texture2D
    load_textures
  end

  def texture_file_name
    "player"
  end

  def draw(draw_collision_box = false)
    LibRay.draw_texture_v(direction_textures[direction.value], LibRay::Vector2.new(x: loc.x, y: loc.y), LibRay::RED)

    if draw_collision_box
      rect = collision_rect
      LibRay.draw_rectangle_lines(rect.x, rect.y, rect.width, rect.height, LibRay::WHITE)
    end
  end

  def movement(collision_rects)
  end
end
