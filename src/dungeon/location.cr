class Location
  property x : Float32
  property y : Float32

  def initialize(@x : Float32, @y : Float32)
  end

  def initialize(x : Int32, y : Int32)
    @x = x.to_f32
    @y = y.to_f32
  end

  def initialize(x : Int32, @y : Float32)
    @x = x.to_f32
  end

  def initialize(@x : Float32, y : Int32)
    @y = y.to_f32
  end
end
