class Wall
  property loc : Location
  property width : Float32
  property height : Float32

  def initialize(@loc : Location, @width : Float32, @height : Float32)
  end

  def initialize(@loc : Location, width : Int32, height : Int32)
    @width = width.to_f32
    @height = height.to_f32
  end

  def initialize(@loc : Location, @width : Int32, height : Float32)
    @height = height.to_f32
  end

  def initialize(@loc : Location, width : Float32, @height : Int32)
    @width = width.to_f32
  end

  def draw(draw_collision_box = false)
    LibRay.draw_rectangle_v(
      LibRay::Vector2.new(x: loc.x, y: loc.y),
      LibRay::Vector2.new(x: width, y: height),
      LibRay::RED
    )

    if draw_collision_box
      rect = collision_rect
      LibRay.draw_rectangle_lines(rect.x, rect.y, rect.width, rect.height, LibRay::WHITE)
    end
  end

  def collision_rect
    rect = LibRay::Rectangle.new
    rect.x = loc.x
    rect.y = loc.y
    rect.width = width
    rect.height = height
    rect
  end
end
