class Player
  property loc : Location
  property width : Int32
  property height : Int32
  property texture : LibRay::Texture2D

  PLAYER_MOVEMENT = 300

  def initialize(@loc : Location, @width : Int32, @height : Int32)
    image = LibRay.load_image(File.join(__DIR__, "assets/player.png"))
    @texture = LibRay.load_texture_from_image(image)
  end

  def collision_rect
    rect = LibRay::Rectangle.new
    rect.x = loc.x - width / 2
    rect.y = loc.y - height / 2
    rect.width = width
    rect.height = height
    rect
  end

  def draw(draw_collision_box = false)
    LibRay.draw_texture(texture, loc.x - width / 2, loc.y - height / 2, LibRay::WHITE)

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
