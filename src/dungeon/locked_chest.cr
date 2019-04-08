require "./item"

module Dungeon
  class LockedChest < Chest
    getter? opened

    def initialize(loc : Location, @level : Level, @player : Player, animation_row = 0, animation_fps = 0)
      super(
        loc: loc,
        level: level,
        player: player,
        animation_row: animation_row,
        animation_fps: animation_fps,
      )

      @animation.tint = LibRay::BROWN
    end

    def pick_up
      return if opened? || !@player.key?

      @player.use_key

      super
    end

    def collidable?
      true
    end
  end
end
