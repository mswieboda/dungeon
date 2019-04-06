require "./item"

module Dungeon
  class BombItem < Item
    def initialize(loc : Location, @player : Player, animation_row = 0, animation_fps = 0)
      super(loc, Sprite.get("bomb"), animation_row, animation_fps)
    end

    def pick_up
      super

      @player.add_bomb
    end
  end
end
