require "./item"

module Dungeon
  class Key < Item
    def initialize(loc : Location, @player : Player, animation_row = 0, animation_fps = 6)
      super(loc, Sprite.get("items/keys"), animation_row, animation_fps)
    end

    def pick_up
      super

      @player.add_key
    end
  end
end
