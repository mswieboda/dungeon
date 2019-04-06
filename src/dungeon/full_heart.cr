require "./item"

module Dungeon
  class FullHeart < Item
    HIT_POINTS = 10

    def initialize(loc : Location, @player : Player, animation_frames = 2, animation_rows = 3, animation_row = 0, animation_fps = 6)
      super(loc, Sprite.load("items/hearts"), animation_frames, animation_rows, animation_row, animation_fps)
    end

    def pick_up
      return if @player.max_hit_points?

      super

      @player.heal(HIT_POINTS)
    end
  end
end
