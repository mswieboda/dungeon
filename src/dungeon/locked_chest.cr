require "./item"

module Dungeon
  class LockedChest < Chest
    getter? opened

    CHANCES = 5

    ITEM_POOL = [
      {
        # hearts
        chance: 0.3,
        items:  [
          {
            chance: 0.7,
            klass:  FullHeart,
          },
          {
            chance: 0.3,
            klass:  HalfHeart,
          },
        ],
      },
      {
        # weapon refill pickups
        chance: 0.3,
        items:  [
          {
            chance: 0.7,
            klass:  BombItem,
          },
          {
            chance: 0.3,
            klass:  ArrowItem,
          },
        ],
      },
      {
        # keys
        chance: 0.25,
        items:  [
          {
            chance: 1.0,
            klass:  Key,
          },
        ],
      },
    ]

    @@item_pool : Array(NamedTuple(chance_max: Int32, klass: String))
    @@item_pool = ItemPool.generate_item_pool(ITEM_POOL)

    def initialize(loc : Location, room : Room, @player : Player, animation_row = 0, animation_fps = 0)
      super(
        loc: loc,
        room: room,
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

    def chances
      CHANCES
    end

    def collidable?
      true
    end
  end
end
