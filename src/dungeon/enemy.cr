require "./living_entity"

module Dungeon
  class Enemy < LivingEntity
    @animation : Animation

    BUMP_DAMAGE = 5

    def initialize(loc : Location, sprite : Sprite, collision_box : Box, tint : LibRay::Color, @direction = Direction::Up)
      @animation = Animation.new(sprite: sprite)

      width = @animation.width
      height = @animation.height

      hit_box = Box.new(
        loc: Location.new(-width / 2, -height / 2),
        width: width,
        height: height
      )

      super(loc, width, height, collision_box, hit_box, tint)

      @animation.tint = @tint
      @animation.row = @direction.value
    end

    def tint!(tint : LibRay::Color)
      @tint = tint
      @animation.tint = tint
    end

    def draw
      @animation.draw(@screen_x, @screen_y)

      if draw_collision_box?
        draw_collision_box
        draw_hit_box
      end

      draw_hit_points if draw_hit_points?
    end

    def bump_damage
      BUMP_DAMAGE
    end

    def collidable?
      true
    end
  end
end
