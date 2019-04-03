module Dungeon
  class Entity
    property loc : Location
    property width : Float32
    property height : Float32
    property collision_box : Box
    property origin : Location
    property tint : LibRay::Color

    TINT_DEFAULT = LibRay::WHITE

    DRAW_COLLISION_BOXES = false

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      @tint = TINT_DEFAULT
      @origin = Location.new(
        x: collision_box.x + collision_box.width / 2,
        y: collision_box.y + collision_box.height / 2
      )
    end

    def initialize(@loc : Location, width : Int32, height : Int32, @collision_box : Box)
      width = width.to_f32
      height = height.to_f32
      initialize(loc: loc, width: width, height: height, collision_box: collision_box)
    end

    def initialize(@loc : Location, @width : Int32, height : Float32, @collision_box : Box)
      height = height.to_f32
      initialize(loc: loc, width: width, height: height, collision_box: collision_box)
    end

    def initialize(@loc : Location, width : Float32, @height : Int32, @collision_box : Box)
      @width = width.to_f32
      initialize(loc: loc, width: width, height: height, collision_box: collision_box)
    end

    def initialize(@loc : Location, @width : Float32, @height : Float32)
      collision_box = Box.new(
        loc: Location.new(width / -2, height / -2),
        width: width,
        height: height
      )
      initialize(loc: loc, width: width, height: height, collision_box: collision_box)
    end

    def initialize(@loc : Location, width : Int32, height : Int32)
      width = width.to_f32
      height = height.to_f32
      initialize(loc: loc, width: width, height: height)
    end

    def initialize(@loc : Location, width : Int32, @height : Float32)
      width = width.to_f32
      initialize(loc: loc, width: width, height: height)
    end

    def initialize(@loc : Location, @width : Float32, height : Int32)
      height = height.to_f32
      initialize(loc: loc, width: width, height: height)
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

    def draw(draw_collision_box = false)
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
    end

    def update(_entities)
      raise "implement in super class"
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
    end
  end
end
