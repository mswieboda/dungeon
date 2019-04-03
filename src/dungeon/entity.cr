module Dungeon
  class Entity
    property loc : Location
    property width : Int32 | Float32
    property height : Int32 | Float32
    property collision_box : Box
    property origin : Location
    property tint : LibRay::Color

    TINT_DEFAULT = LibRay::WHITE

    DRAW_COLLISION_BOXES = false

    def initialize(@loc : Location, @width, @height, @collision_box : Box, @tint = TINT_DEFAULT)
      @origin = Location.new(
        x: collision_box.x + collision_box.width / 2,
        y: collision_box.y + collision_box.height / 2
      )
    end

    def initialize(loc, width, height, tint = TINT_DEFAULT)
      collision_box = Box.new(
        loc: Location.new(-width / 2, -height / 2),
        width: width,
        height: height
      )
      initialize(loc, width, height, collision_box, tint)
    end

    def x=(x)
      @loc.x = x
    end

    def x
      @loc.x
    end

    def y=(y)
      @loc.y = y
    end

    def y
      @loc.y
    end

    def draw_collision_box?
      DRAW_COLLISION_BOXES
    end

    def draw
      raise "implement in super class"
    end

    def draw_collision_box(box : Box = collision_box)
      LibRay.draw_rectangle_lines(
        pos_x: x + box.x,
        pos_y: y + box.y,
        width: box.width,
        height: box.height,
        color: LibRay::WHITE
      )

      # draw origin
      line_size = 5

      # x line
      LibRay.draw_line_bezier(
        start_pos: LibRay::Vector2.new(x: x + origin.x + line_size, y: y + origin.y),
        end_pos: LibRay::Vector2.new(x: x + origin.x - line_size, y: y + origin.y),
        thick: 1,
        color: LibRay::MAGENTA
      )

      # y line
      LibRay.draw_line_bezier(
        start_pos: LibRay::Vector2.new(x: x + origin.x, y: y + origin.y + line_size),
        end_pos: LibRay::Vector2.new(x: x + origin.x, y: y + origin.y - line_size),
        thick: 1,
        color: LibRay::MAGENTA
      )
    end

    def update(_entities)
    end

    # used for checking for movement collisions
    def collidable?
      false
    end

    def collisions?(entities : Array(Entity))
      entities.any? { |entity| collision?(entity) }
    end

    def collision?(entity : Entity)
      x + collision_box.x < entity.x + entity.collision_box.x + entity.collision_box.width &&
        x + collision_box.x + collision_box.width > entity.x + entity.collision_box.x &&
        y + collision_box.y < entity.y + entity.collision_box.y + entity.collision_box.height &&
        y + collision_box.y + collision_box.height > entity.y + entity.collision_box.y
    end

    def removed?
      false
    end
  end
end
