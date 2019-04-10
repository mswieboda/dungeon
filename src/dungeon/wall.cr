module Dungeon
  class Wall < Entity
    TINT_DEFAULT = LibRay::RED

    def initialize(loc : Location, width, height, tint = TINT_DEFAULT)
      collision_box = Box.new(
        loc: Location.new(0, 0),
        width: width,
        height: height
      )
      super(loc, width, height, collision_box, tint)
      @centered = false
    end

    def draw
      LibRay.draw_rectangle_v(
        LibRay::Vector2.new(x: @screen_x, y: @screen_y),
        LibRay::Vector2.new(x: width, y: height),
        @tint
      )

      draw_collision_box if draw_collision_box?
    end

    def collidable?
      true
    end
  end
end
