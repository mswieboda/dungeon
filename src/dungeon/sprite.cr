module Dungeon
  class Sprite
    @@sprites = Hash(String, LibRay::Texture2D).new

    DEBUG = false

    def self.load(asset_files : Array(String))
      asset_files.each { |asset_file| load(asset_file) }
    end

    def self.load(asset_file : String)
      @@sprites[asset_file] ||= load_texture(asset_file)

      sprite = @@sprites[asset_file]

      puts "sprite loaded: #{asset_file}" if DEBUG

      sprite
    end

    def self.load_texture(asset_file)
      puts "loading texture: #{asset_file}" if DEBUG

      texture = LibRay.load_texture(File.join(__DIR__, "assets/#{asset_file}.png"))

      puts "loaded texture: #{asset_file}" if DEBUG

      texture
    end
  end
end
