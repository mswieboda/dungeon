module Dungeon
  class Wall < Entity
    def draw
      LibRay.draw_rectangle_v(
        LibRay::Vector2.new(x: loc.x - width / 2, y: loc.y - height / 2),
        LibRay::Vector2.new(x: width, y: height),
        LibRay::RED
      )

      draw_collision_box if draw_collision_box?
    end

    def update(_entities)
    end
  end
end
