module Dungeon
  class Animation
    property tint : LibRay::Color
    property row : Int32
    property rotation : Float32
    property fps : Int32
    property? loop_infinitely : Bool

    getter sprite : Sprite
    getter frames : Int32
    getter width : Int32
    getter height : Int32

    TINT_DEFAULT = LibRay::WHITE

    def initialize(@sprite : Sprite, @row = 0, @frame_initial = 0, @fps = 24, @tint = TINT_DEFAULT, @loop_infinitely = true)
      @frames = @sprite.frames
      @width = @sprite.width
      @height = @sprite.height
      @frame_t = 0_f32 + @frame_initial
      @rotation = 0_f32
      @done = false
    end

    def frame
      @frame_t.to_i
    end

    def frame=(frame)
      @frame_t = frame.to_f32
    end

    def draw(x, y)
      LibRay.draw_texture_pro(
        texture: @sprite.texture,
        source_rec: LibRay::Rectangle.new(
          x: frame * width,
          y: @row * height,
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
        rotation: @rotation,
        tint: tint
      )
    end

    def update(delta_t : Float32)
      return if @fps <= 0

      @frame_t += delta_t * @fps
      @done = false

      if @frame_t >= @frames
        @done = true

        restart if loop_infinitely?
      end
    end

    def restart
      @frame_t = 0_f32
    end

    def done?
      return true if @fps == 0
      @done
    end
  end
end
