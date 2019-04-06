require "./enemy"

module Dungeon
  class BasicEnemy < Enemy
    def initialize(loc : Location, @direction = Direction::Up)
      sprite = Sprite.get("player")
      tint = LibRay::ORANGE

      collision_box = Box.new(
        loc: Location.new(-12, 16),
        width: 24,
        height: 16
      )

      super(loc, sprite, collision_box, tint, @direction)
    end
  end
end
