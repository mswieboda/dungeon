module Dungeon
  class SpikyFloor < Wall
    TINT_DEFAULT = LibRay::GRAY

    BUMP_DAMAGE = 5

    def initialize(loc : Location, width, height)
      collision_box = Box.new(
        loc: Location.new(0, 0),
        width: width,
        height: height
      )
      super(loc, width, height, TINT_DEFAULT)
      @centered = false
      @bottom_layer = true
    end

    def bump_damage
      BUMP_DAMAGE
    end

    def collidable?
      false
    end
  end
end
