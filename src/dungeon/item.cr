module Dungeon
  class Item < Entity
    @animation : Animation

    def initialize(loc : Location, sprite : LibRay::Texture2D, animation_frames = 1, animation_rows = 1, animation_row = 0, animation_fps = 24)
      @animation = Animation.new(
        sprite: sprite,
        frames: animation_frames,
        rows: animation_rows,
        row: animation_row,
        fps: animation_fps
      )

      width = @animation.width
      height = @animation.height
      collision_box = Box.new(loc: Location.new(-width / 2, -height / 2), width: width, height: height)

      super(loc, width, height, collision_box)

      @animation.tint = tint
    end

    def draw
      @animation.draw(x, y)

      draw_collision_box if draw_collision_box?
    end

    def update(_entities)
      delta_t = LibRay.get_frame_time

      @animation.update(delta_t)
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
