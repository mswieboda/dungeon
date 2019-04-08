require "./item"

module Dungeon
  class Chest < Item
    getter? opened

    CHANCES = 3

    ITEM_POOL = [
      {
        # hearts
        chance: 0.15,
        items:  [
          {
            chance: 0.4,
            klass:  FullHeart,
          },
          {
            chance: 0.6,
            klass:  HalfHeart,
          },
        ],
      },
      {
        # weapon refill pickups
        chance: 0.1,
        items:  [
          {
            chance: 0.4,
            klass:  BombItem,
          },
          {
            chance: 0.6,
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

    def initialize(loc : Location, @level : Level, @player : Player, animation_row = 0, animation_fps = 0)
      super(
        loc: loc,
        sprite: Sprite.get("items/chests"),
        animation_row: animation_row,
        animation_fps: animation_fps,
        hit_box_padding: 5
      )

      @opened = false
    end

    def pick_up
      return if opened?

      @opened = true

      @animation.frame = 1

      drop_items
    end

    def chances
      CHANCES
    end

    def drop_items
      items = [] of Item

      chances.times do |chance|
        item = item_chance
        items << item if item
      end

      while items.empty?
        item = item_chance
        items << item if item
      end

      position_items(items)

      @level.add_entities(items)
    end

    def item_chance
      rand = rand(100)
      item = ItemPool.get_new_item(@@item_pool, rand, @level, @player)
    end

    def position_items(items)
      # TODO: randomly arrange item locations
      # don't overlap anything else

      item_x = x + width + 15

      items.each do |item|
        item.x = item_x
        item.y = y

        item_x += item.width + 15
      end
    end

    def collidable?
      true
    end
  end
end
