class Entity
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

  def collision_rect
    rect = LibRay::Rectangle.new
    rect.x = loc.x
    rect.y = loc.y
    rect.width = width
    rect.height = height
    rect
  end

  def draw(draw_collision_box = false)
    raise "implement in super class"
  end

  def movement(collision_rects)
    raise "implement in super class"
  end

  def collisions?(collision_rects : Array(LibRay::Rectangle))
    collision_rects.any? { |other_collision_rect| collision?(collision_rect, other_collision_rect) }
  end

  def collision?(rect1, rect2)
    rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x && rect1.y < rect2.y + rect2.height && rect1.y + rect1.height > rect2.y
  end
end
