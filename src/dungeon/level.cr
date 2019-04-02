require "./location"

module Dungeon
  class Level
    getter level_width : Int32
    getter level_height : Int32
    getter player_location : Location
    getter player : Player
    getter drawables
    getter collidables

    DRAW_COLLISION_BOXES = true

    def initialize(@level_width, @level_height)
      @drawables = [] of Entity
      @collidables = [] of Entity

      @player_location = Location.new(150, 150)
      @player = Player.new(
        loc: @player_location,
        width: 48,
        height: 64,
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        )
      )

      @collidables << Wall.new(loc: Location.new(level_width / 2, 16), width: level_width, height: 32)
      @collidables << Wall.new(loc: Location.new(level_width - 16, level_height / 2), width: 32, height: level_height)
      @collidables << Wall.new(loc: Location.new(level_width / 2, level_height - 16), width: level_width, height: 32)
      @collidables << Wall.new(loc: Location.new(16, level_height / 2), width: 32, height: level_height)
      @collidables << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # enemies
      @collidables << Enemy.new(
        loc: Location.new(300, 300),
        width: 48,
        height: 64,
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

      @collidables.each { |entity| entity.update(@collidables) unless entity.removed? }

      @player.update(@collidables)

      @collidables.reject!(&.removed?)

      # change order of drawing based on y coordinates
      @drawables.concat(@collidables)
      @drawables << @player
      @drawables.sort_by!(&.y)
    end
  end
end
