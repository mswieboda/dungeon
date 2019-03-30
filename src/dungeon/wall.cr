class Wall
  property loc : Location
  property width : Int32
  property size : Int32
  property direction : Int32 # TODO: switch to enum or class

  def initialize(@loc : Location, @width : Int32, @size : Int32, @direction : Int32)
  end

  def draw
    LibRay.draw_rectangle(loc.x, loc.y, size, width, LibRay::RED)
  end
end
