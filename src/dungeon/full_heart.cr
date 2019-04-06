require "./item"

module Dungeon
  class FullHeart < Item
    HIT_POINTS = 10

    def initialize(loc : Location, @player : Player, animation_row = 0, animation_fps = 6)
      super(loc, Sprite.get("items/hearts"), animation_row, animation_fps)
    end

    def pick_up
      return if @player.max_hit_points?

      super

      @player.heal(HIT_POINTS)
    end
  end
end
