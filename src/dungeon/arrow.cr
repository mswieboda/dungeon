require "./weapon"

module Dungeon
  class Arrow < Weapon
    getter? active

    MOVEMENT = 500

    def initialize(loc : Location, direction : Direction)
      sprite = Sprite.get("arrow")

      collision_box = Box.new(
        loc: Location.new(-sprite.width / 2, -sprite.height / 2),
        width: sprite.width,
        height: sprite.height
      )

      super(loc, direction, sprite, collision_box: collision_box)

      @animation.fps = 12
      @active = true

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

    def draw
      @animation.draw(@screen_x, @screen_y)

      draw_collision_box if draw_collision_box?
    end

    def update(entities)
      return unless active?

      delta_t = LibRay.get_frame_time

      @animation.update(delta_t)

      move(delta_t)

      attack(entities.select(&.is_a?(LivingEntity)).map(&.as(LivingEntity)))

      return unless active?

      if collisions?(entities.select(&.collidable?))
        @active = false
      end
    end

    def move(delta_t)
      if direction.up?
        @loc.y -= delta_t * MOVEMENT
      elsif direction.down?
        @loc.y += delta_t * MOVEMENT
      elsif direction.left?
        @loc.x -= delta_t * MOVEMENT
      elsif direction.right?
        @loc.x += delta_t * MOVEMENT
      end
    end

    def hit?(entity : LivingEntity)
      collision?(entity, entity.hit_box)
    end

    def attack(entities : Array(LivingEntity))
      entities.each do |entity|
        if hit?(entity)
          entity.hit(DAMAGE)
          @active = false
        end
      end
    end
  end
end
