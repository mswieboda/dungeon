require "./item"

module Dungeon
  class Key < Item
    def initialize(loc : Location, animation_row = 0, animation_fps = 6)
      super(loc, Sprite.get("items/keys"), animation_row, animation_fps)
    end
  end
end
