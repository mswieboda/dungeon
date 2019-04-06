require "./entity"

module Dungeon
  class Item < Entity
    @animation : Animation

    def initialize(loc : Location, sprite : Sprite, animation_row = 0, animation_fps = 24, hit_box_padding = 0)
      @animation = Animation.new(
        sprite: sprite,
        row: animation_row,
        fps: animation_fps
      )

      width = @animation.width
      height = @animation.height
      collision_box = Box.new(loc: Location.new(-width / 2, -height / 2), width: width, height: height)

      hit_box = Box.new(
        loc: Location.new(
          x: -(width + hit_box_padding * 2) / 2,
          y: -(height + hit_box_padding * 2) / 2
        ),
        width: width + hit_box_padding * 2,
        height: height + hit_box_padding * 2
      )

      super(loc, width, height, collision_box, hit_box)

      @animation.tint = @tint
    end

    def draw
      @animation.draw(x, y)

      if draw_collision_box?
        draw_collision_box
        draw_hit_box
      end
    end

    def update(_entities)
      delta_t = LibRay.get_frame_time

      @animation.update(delta_t)
    end

    def pick_up
      remove
    end

    def collidable?
      false
    end

    def remove
      @removed = true
    end

    def removed?
      @removed
    end
  end
end
