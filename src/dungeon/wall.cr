class Wall
  property loc : Location
  property size : Int32
  property thickness : Int32
  property direction : Int32 # TODO: switch to enum or class
  property width : Int32
  property height : Int32

  def initialize(@loc : Location, @size : Int32, @thickness : Int32, @direction : Int32)
    @width = @height = 0
    set_direction
  end

  def set_direction
    if direction == 1 # left to right
      @width = size
      @height = thickness
    elsif direction == 2 # up to down
      @width = thickness
      @height = size
    elsif direction == 3 # right to left
      @width = -size
      @height = -thickness
    elsif direction == 2 # down to up
      @width = -thickness
      @height = -size
    else
      @width = height = 0
    end
  end

  def draw(draw_collision_box = false)
    LibRay.draw_rectangle(loc.x, loc.y, width, height, LibRay::RED)

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
