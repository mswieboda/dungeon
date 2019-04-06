require "./location"

module Dungeon
  class Level
    @width : Int32
    @height : Int32

    @player : Player

    def initialize(@player, @width, @height)
      @drawables = [] of Entity
      @entities = [] of Entity

      # load sprites
      keys_sprite = Sprite.get("items/keys")

      # player
      @entities << @player

      # walls
      @entities << Wall.new(loc: Location.new(width / 2, 16), width: width, height: 32)
      @entities << Wall.new(loc: Location.new(width - 16, height / 2), width: 32, height: height)
      @entities << Wall.new(loc: Location.new(width / 2, height - 16), width: width, height: 32)
      @entities << Wall.new(loc: Location.new(16, height / 2), width: 32, height: height)
      @entities << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # items
      @entities << Key.new(loc: Location.new(300, 150))
      @entities << FullHeart.new(loc: Location.new(200, 150), player: @player)
      @entities << HalfHeart.new(loc: Location.new(250, 150), player: @player)

      # enemies
      @entities << Enemy.new(
        loc: Location.new(300, 300),
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        )
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
