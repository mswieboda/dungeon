class Player
  property x : Float32
  property y : Float32
  property width : Float32
  property height : Float32
  property rotation : Float32

  PLAYER_MOVEMENT = 300

  def initialize(@x : Float32, @y : Float32, @width : Float32, @height : Float32, @rotation : Float32)
  end

  def collision_rect
    rect = LibRay::Rectangle.new
    rect.x = x
    rect.y = y
    rect.width = width
    rect.height = height
    rect
  end

  def draw
    # v1 = LibRay::Vector2.new(x: x, y: y - height / 2)
    # v2 = LibRay::Vector2.new(x: x - width / 2, y: y + height / 2)
    # v3 = LibRay::Vector2.new(x: x + width / 2, y: y + height / 2)

    v1 = LibRay::Vector2.new(x: rotated_x(x, y - height / 2), y: rotated_y(x, y - height / 2))
    v2 = LibRay::Vector2.new(x: rotated_x(x - width / 2, y + height / 2), y: rotated_y(x - width / 2, y + height / 2))
    v3 = LibRay::Vector2.new(x: rotated_x(x + width / 2, y + height / 2), y: rotated_y(x + width / 2, y + height / 2))

    # v1 = LibRay::Vector2.new(x: rotated_x(x, y - height / 2), y: rotated_y(x, y - height / 2))
    # puts "v1: (#{x},#{y - height / 2}) rotated_v1: (#{v1.x},#{v1.y})"
    # v2 = LibRay::Vector2.new(x: rotated_x(x - width / 2, y + height / 2), y: rotated_y(x - width / 2, y + height / 2))
    # puts "v2: (#{x - width / 2},#{y + height / 2}) rotated_v2: (#{v2.x},#{v2.y})"
    # v3 = LibRay::Vector2.new(x: rotated_x(x + width / 2, y + height / 2), y: rotated_y(x + width / 2, y + height / 2))
    # puts "v3: (#{x + width / 2},#{y + height / 2}) rotated_v3: (#{v3.x},#{v3.y})"

    # v1: (512.0,374.0) rotated_v1: (-374.00003,511.99997)
    # v2: (502.0,394.0) rotated_v2: (-394.00003,501.99997)
    # v3: (522.0,394.0) rotated_v3: (-394.00003,522.0)

    # puts "v1 delta: (#{x - rotated_x(x, y - height / 2)},#{y - rotated_y(x, y - height / 2)})"

    LibRay.draw_triangle(
      v1,
      v2,
      v3,
      LibRay::RED
    )
    # puts "xy: (#{x},#{y}) v1: (#{v1.x},#{v1.y}) v2: (#{v2.x},#{v2.y}) v3: (#{v3.x},#{v3.y})"
    # LibRay.draw_rectangle(x, y, width, height, LibRay::RED)
    # LibRay.draw_rectangle_v(LibRay::Vector2.new(x: x, y: y), LibRay::Vector2.new(x: width, y: height), LibRay::RED)
  end

  def to_rad(degrees : Float32)
    degrees += 180
    degrees * (Math::PI / 180.0)
  end

  def rotated_x(rx, ry)
    x + ((x - rx) * Math.cos(to_rad(rotation)) - (y - ry) * Math.sin(to_rad(rotation)))
  end

  def rotated_y(rx, ry)
    y + ((x - rx) * Math.sin(to_rad(rotation)) + (y - ry) * Math.cos(to_rad(rotation)))
  end

  def movement(collision_rects)
    delta_t = LibRay.get_frame_time
    delta = delta_t * PLAYER_MOVEMENT

    # rotation of shape/sprite
    if LibRay.key_pressed?(LibRay::KEY_W)
      @rotation = 0
    end

    if LibRay.key_pressed?(LibRay::KEY_A)
      @rotation = -90
    end

    if LibRay.key_pressed?(LibRay::KEY_S)
      @rotation = 180
    end

    if LibRay.key_pressed?(LibRay::KEY_D)
      @rotation = 90
    end

    # movement
    if LibRay.key_down?(LibRay::KEY_W)
      @y -= delta unless collisions?(x: x, y: y - delta, collision_rects: collision_rects)
    end

    if LibRay.key_down?(LibRay::KEY_A)
      @x -= delta unless collisions?(x: x - delta, y: y, collision_rects: collision_rects)
    end

    if LibRay.key_down?(LibRay::KEY_S)
      @y += delta unless collisions?(x: x, y: y + delta, collision_rects: collision_rects)
    end

    if LibRay.key_down?(LibRay::KEY_D)
      @x += delta unless collisions?(x: x + delta, y: y, collision_rects: collision_rects)
    end
  end

  def collisions?(x : Float32, y : Float32, collision_rects : Array(LibRay::Rectangle))
    rect1 = collision_rect
    rect1.x = x
    rect1.y = y

    collision_rects.any? { |collision_rect| collision?(rect1, collision_rect) }
  end

  def collision?(rect1, rect2)
    rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x && rect1.y < rect2.y + rect2.height && rect1.y + rect1.height > rect2.y
  end
end
