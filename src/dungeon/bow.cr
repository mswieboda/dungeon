require "./weapon"

module Dungeon
  class Bow < Weapon
    property arrows_left : Int32
    getter arrows : Array(Arrow)
    TIMER = 15

    def initialize(loc : Location, direction : Direction)
      sprite = Sprite.get("arrow")

      collision_box = Box.new(
        loc: Location.new(-sprite.width / 2, -sprite.height / 2),
        width: sprite.width,
        height: sprite.height
      )

      super(loc, direction, sprite, collision_box: collision_box)

      @animation.fps = 0

      @timer = 0
      @arrows = [] of Arrow
      @arrows_left = 10
    end

    def direction=(direction)
      @direction = direction
      adjust_location_and_dimensions
    end

    def draw
      @arrows.each(&.draw)

      return unless attacking?

      @animation.draw(x, y)

      draw_collision_box if draw_collision_box?
    end

    def attack
      return unless arrows_left?

      @attacking = true
      @timer = 1
    end

    def arrows_left?
      arrows_left > 0
    end

    def update(entities)
      @arrows.each { |arrow| arrow.update(entities) }
      @arrows.reject! { |arrow| !arrow.active? }

      return unless attacking?

      @timer += 1

      @animation.update(LibRay.get_frame_time)

      if @timer >= TIMER
        @timer = 0
        @attacking = false
        fire
      end
    end

    def adjust_location_and_dimensions
      # TODO: move bow, like in Sword

      if direction.up?
        @animation.rotation = 180
      elsif direction.down?
        @animation.rotation = 0
      elsif direction.left?
        @animation.rotation = 90
      elsif direction.right?
        @animation.rotation = -90
      end
    end

    def fire
      return unless arrows_left?

      @arrows_left -= 1
      arrow = Arrow.new(
        loc: Location.new(x, y),
        direction: direction
      )

      @arrows << arrow
    end
  end
end
