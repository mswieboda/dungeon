require "./entity"

class Player < Entity
  include DirectionTextures

  PLAYER_MOVEMENT = 200

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
    LibRay.draw_texture_v(direction_textures[direction.value], LibRay::Vector2.new(x: loc.x, y: loc.y), LibRay::WHITE)

    if draw_collision_box
      rect = collision_rect
      LibRay.draw_rectangle_lines(rect.x, rect.y, rect.width, rect.height, LibRay::WHITE)
    end
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
