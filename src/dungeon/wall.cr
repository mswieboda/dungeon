class Wall < Entity
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
end
