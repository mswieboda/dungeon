require "./item"

module Dungeon
  class Chest < Item
    getter? opened

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

      items = [] of Item

      items << BombItem.new(loc: Location.new, player: @player)
      items << Key.new(loc: Location.new, player: @player)

      # TODO: randomly arrange item locations
      # don't overlap anything else

      item_x = x + width + 15

      items.each do |item|
        item.x = item_x
        item.y = y

        item_x += item.width + 15
      end

      @level.add_entities(items)
    end

    def collidable?
      true
    end
  end
end
