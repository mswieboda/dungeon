module Dungeon
  class Sprite
    getter texture : LibRay::Texture2D
    getter width : Int32
    getter height : Int32
    getter asset_file : String
    getter frames : Int32
    getter rows : Int32

    @@textures = Hash(String, LibRay::Texture2D).new
    @@sprites = Hash(String, Sprite).new

    DEBUG = false

    def initialize(@asset_file, @frames, @rows)
      @texture = LibRay::Texture2D.new
      @width = 0
      @height = 0

      get_texture
    end

    def get_texture
      @texture = self.class.get_texture(@asset_file)
      @width = @texture.width / @frames
      @height = @texture.height / @rows
    end

    def self.load(sprites : Array(NamedTuple(asset_file: String, frames: Int32, rows: Int32)))
      sprites.each { |sprite| load(sprite[:asset_file], sprite[:frames], sprite[:rows]) }
    end

    def self.load(asset_file : String, frames, rows)
      unless @@sprites.has_key?(asset_file)
        @@sprites[asset_file] = Sprite.new(asset_file, frames, rows)
      end

      sprite = @@sprites[asset_file]

      puts "sprite loaded: #{asset_file}" if DEBUG

      sprite
    end

    def self.load_texture(asset_file)
      puts "loading texture: #{asset_file}" if DEBUG

      @@textures[asset_file] ||= LibRay.load_texture(File.join(__DIR__, "assets/#{asset_file}.png"))

      texture = @@textures[asset_file]

      puts "loaded texture: #{asset_file}" if DEBUG

      texture
    end

    def self.get_texture(asset_file)
      puts "getting texture: #{asset_file}" if DEBUG

      unless @@textures.has_key?(asset_file)
        texture = load_texture(asset_file)
      end

      texture = @@textures[asset_file]

      puts "got texture: #{asset_file}" if DEBUG

      texture
    end

    def self.get(asset_file)
      puts "getting sprite: #{asset_file}" if DEBUG

      sprite = @@sprites[asset_file]

      unless sprite
        raise "sprite: #{asset_file} not found, make sure to load first with Sprite.load before using"
      end

      puts "got sprite: #{asset_file}" if DEBUG

      sprite
    end
  end
end
