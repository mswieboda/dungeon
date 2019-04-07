module Dungeon
  class Entity
    property loc : Location
    property width : Int32
    property height : Int32
    property collision_box : Box
    getter hit_box : Box
    property origin : Location

    @tint : LibRay::Color

    TINT_DEFAULT = LibRay::WHITE

    DRAW_COLLISION_BOXES = Game::DEBUG

    def initialize(@loc : Location, @width, @height, @collision_box : Box, @hit_box : Box, @tint = TINT_DEFAULT)
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
      initialize(loc, width, height, collision_box, collision_box, tint)
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

    def draw_collision_box
      LibRay.draw_rectangle_lines(
        pos_x: x + collision_box.x,
        pos_y: y + collision_box.y,
        width: collision_box.width,
        height: collision_box.height,
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

    def draw_hit_box
      LibRay.draw_rectangle_lines(
        pos_x: x + @hit_box.x,
        pos_y: y + @hit_box.y,
        width: @hit_box.width,
        height: @hit_box.height,
        color: LibRay::WHITE
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

    def collision?(entity : Entity, box : Box = entity.collision_box)
      x + collision_box.x < entity.x + box.x + box.width &&
        x + collision_box.x + collision_box.width > entity.x + box.x &&
        y + collision_box.y < entity.y + box.y + box.height &&
        y + collision_box.y + collision_box.height > entity.y + box.y
    end

    def removed?
      false
    end
  end
end
