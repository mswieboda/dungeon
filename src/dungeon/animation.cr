class Animation
  @sprite : LibRay::Texture2D
  @frames : Int32
  @rows : Int32
  @fps : Int32

  property tint : LibRay::Color
  property row : Int32
  property rotation : Float32

  getter width : Int32
  getter height : Int32

  TINT_DEFAULT = LibRay::WHITE

  def initialize(@sprite : LibRay::Texture2D, @frames = 1, @rows = 1, @row = 0, @fps = 24, @tint = TINT_DEFAULT)
    @width = @sprite.width / frames
    @height = @sprite.height / rows
    @frame_t = 0_f32
    @rotation = 0_f32
  end

  def frame_x
    @frame_t.to_i * width
  end

  def frame_y
    @row * height
  end

  def draw(x, y)
    LibRay.draw_texture_pro(
      texture: @sprite,
      source_rec: LibRay::Rectangle.new(
        x: frame_x,
        y: frame_y,
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
    @frame_t += delta_t * @fps

    @frame_t = 0_f32 if @frame_t >= @frames
  end

  def restart!
    @frame_t = 0_f32
  end
end
