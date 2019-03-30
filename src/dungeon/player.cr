class Player
  property loc : Location
  property size : Int32

  PLAYER_MOVEMENT = 300

  def initialize(@loc : Location, @size : Int32)
  end

  def collision_rect
    rect = LibRay::Rectangle.new
    rect.x = loc.x - size / 2
    rect.y = loc.y - size / 2
    rect.width = size
    rect.height = size
    rect
  end

  def draw
    v1 = LibRay::Vector2.new(x: loc.x, y: loc.y - size / 2)
    v2 = LibRay::Vector2.new(x: loc.x - size / 2, y: loc.y + size / 2)
    v3 = LibRay::Vector2.new(x: loc.x + size / 2, y: loc.y + size / 2)

    LibRay.draw_triangle(
      v1,
      v2,
      v3,
      LibRay::RED
    )

    # collision box
    rect = collision_rect
    LibRay.draw_rectangle_lines(rect.x, rect.y, rect.width, rect.height, LibRay::WHITE)
  end

  def movement(collision_rects)
    delta_t = LibRay.get_frame_time
    delta = delta_t * PLAYER_MOVEMENT

    # movement
    if LibRay.key_down?(LibRay::KEY_W)
      @loc.y -= delta
      @loc.y += delta if collisions?(collision_rects)
    end

    if LibRay.key_down?(LibRay::KEY_A)
      @loc.x -= delta
      @loc.x += delta if collisions?(collision_rects)
    end

    if LibRay.key_down?(LibRay::KEY_S)
      @loc.y += delta
      @loc.y -= delta if collisions?(collision_rects)
    end

    if LibRay.key_down?(LibRay::KEY_D)
      @loc.x += delta
      @loc.x -= delta if collisions?(collision_rects)
    end
  end

  def collisions?(collision_rects : Array(LibRay::Rectangle))
    collision_rects.any? { |other_collision_rect| collision?(collision_rect, other_collision_rect) }
  end

  def collision?(rect1, rect2)
    rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x && rect1.y < rect2.y + rect2.height && rect1.y + rect1.height > rect2.y
  end
end
