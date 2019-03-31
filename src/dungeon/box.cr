module Dungeon
  class Box
    property loc : Location
    property width : Float32
    property height : Float32

    def initialize(@loc : Location, @width : Float32, @height : Float32)
    end

    def initialize(@loc : Location, width : Int32, height : Int32)
      @width = width.to_f32
      @height = height.to_f32
    end

    def initialize(@loc : Location, width : Int32, @height : Float32)
      @width = width.to_f32
    end

    def initialize(@loc : Location, @width : Float32, height : Int32)
      @height = height.to_f32
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
  end
end
