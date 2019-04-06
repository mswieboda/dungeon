module Dungeon
  class Weapon < Entity
    getter direction : Direction
    getter? attacking

    @animation : Animation

    DAMAGE = 5

    def initialize(loc : Location, @direction : Direction, sprite, collision_box : Box)
      @animation = Animation.new(sprite: sprite)

      width = @animation.width
      height = @animation.height

      super(loc, width, height, collision_box)

      @animation.tint = @tint

      @attacking = false
    end

    def draw
      @animation.draw(x, y)

      draw_collision_box if draw_collision_box?
    end

    def attack
      @attacking = true
    end

    def update(entities)
      return unless attacking?

      @animation.update(LibRay.get_frame_time)

      attack(entities.select(&.is_a?(LivingEntity)).map(&.as(LivingEntity)))
    end

    def hit?(entity : LivingEntity)
      collision?(entity, entity.hit_box)
    end

    def attack(entities : Array(LivingEntity))
      entities.each do |entity|
        if hit?(entity)
          entity.hit(DAMAGE)
        end
      end
    end
  end
end
