module Dungeon
  class Item < Entity
    getter sprite : LibRay::Texture2D
    getter frame : Int32

    def initialize(loc : Location, @name : Symbol, frames = 1)
      image = LibRay.load_image(File.join(__DIR__, "assets/items/#{name}.png"))
      @sprite = LibRay.load_texture_from_image(image)

      width = @sprite.width / frames
      height = @sprite.height
      collision_box = Box.new(loc: Location.new(-width / 2, -height / 2), width: width, height: height)

      super(loc, width, height, collision_box)

      @frame = 0
    end

    def draw
      LibRay.draw_texture_pro(
        texture: sprite,
        source_rec: LibRay::Rectangle.new(
          x: frame * width,
          y: 0,
          width: width,
          height: height
        ),
        dest_rec: LibRay::Rectangle.new(
          x: x,
          y: y,
          width: width,
          height: height
        ),
        origin: LibRay::Vector2.new(
          x: width / 2,
          y: height / 2
        ),
        rotation: 0,
        tint: tint
      )

      draw_collision_box if draw_collision_box?
    end

    def collidable?
      false
    end

    def remove
      @removed = true
    end

    def removed?
      @removed
    end
  end
end
