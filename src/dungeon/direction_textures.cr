module DirectionTextures
  getter direction_textures : Array(LibRay::Texture2D)
  getter direction : Direction

  def load_textures
    Direction.each do |dir|
      image = LibRay.load_image(File.join(__DIR__, "assets/#{texture_file_name}-#{dir.to_s.downcase}.png"))
      @direction_textures << LibRay.load_texture_from_image(image)
    end
  end

  def texture_file_name
    raise "implement in included class"
  end
end
