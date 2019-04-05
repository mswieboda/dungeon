require "./location"

module Dungeon
  class Level
    @width : Int32
    @height : Int32

    @player : Player

    def initialize(@player, @width, @height, enemy_sprite, hearts_sprite)
      @drawables = [] of Entity
      @entities = [] of Entity

      # load sprites
      keys_sprite = LibRay.load_texture(File.join(__DIR__, "assets/items/keys.png"))

      # player
      @entities << @player

      # walls
      @entities << Wall.new(loc: Location.new(width / 2, 16), width: width, height: 32)
      @entities << Wall.new(loc: Location.new(width - 16, height / 2), width: 32, height: height)
      @entities << Wall.new(loc: Location.new(width / 2, height - 16), width: width, height: 32)
      @entities << Wall.new(loc: Location.new(16, height / 2), width: 32, height: height)
      @entities << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # items
      @entities << Item.new(loc: Location.new(300, 150), sprite: keys_sprite, animation_rows: 4)
      @entities << Item.new(loc: Location.new(200, 150), sprite: hearts_sprite, animation_frames: 2, animation_rows: 3, animation_row: 0, animation_fps: 5)

      # enemies
      @entities << Enemy.new(
        loc: Location.new(300, 300),
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        ),
        sprite: enemy_sprite
      )
    end

    def draw
      @drawables.each(&.draw)
    end

    def update
      @drawables.clear

      @entities.each { |entity| entity.update(@entities.reject(entity)) unless entity.removed? }
      @entities.reject!(&.removed?)

      # change order of drawing based on y coordinates
      @drawables.concat(@entities)
      @drawables.sort_by!(&.y)
    end
  end
end
