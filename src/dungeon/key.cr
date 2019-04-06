require "./item"

module Dungeon
  class Key < Item
    def initialize(loc : Location, animation_frames = 1, animation_rows = 4, animation_row = 0, animation_fps = 6)
      super(loc, Sprite.load("items/keys"), animation_frames, animation_rows, animation_row, animation_fps)
    end
  end
end
