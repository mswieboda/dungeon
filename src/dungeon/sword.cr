require "./weapon"

module Dungeon
  class Sword < Weapon
    property direction : Direction
    ATTACK_TIME = 16

    DAMAGE = 5

    def initialize(loc : Location, direction : Direction)
      sprite = Sprite.get("sword-attack")

      collision_box = Box.new(
        loc: Location.new(-sprite.width / 2, -sprite.height / 2),
        width: sprite.width,
        height: sprite.height
      )

      super(loc, direction, sprite, collision_box: collision_box)

      @animation.tint = @tint
      @animation.fps = ATTACK_TIME

      @attack_time = 0
    end

    def draw
      return unless attacking?

      @animation.draw(@screen_x, @screen_y)

      draw_collision_box if draw_collision_box?
    end

    def attack
      @attack_time = 0
      @animation.restart
      @attacking = true
    end

    def update_loc(loc, origin, collision_box, player_width, player_height)
      offset_x = offset_y = 0

      case @direction
      when .up?
        offset_y = origin.y - collision_box.height / 2 - height / 2
        offset_x = origin.x
        @animation.rotation = 0
      when .down?
        offset_y = origin.y + collision_box.height / 2 + height / 2
        offset_x = origin.x
        @animation.rotation = 180
      when .left?
        offset_x = -width + origin.x + collision_box.width / 2
        offset_y = origin.y + collision_box.height / 2 - height / 2
        @animation.rotation = -90
      when .right?
        offset_x = width - origin.x - collision_box.width / 2
        offset_y = origin.y + collision_box.height / 2 - height / 2
        @animation.rotation = 90
      end

      @loc.x = loc.x + offset_x
      @loc.y = loc.y + offset_y
    end

    def update(entities)
      return unless attacking?

      # timer
      @attack_time += 1

      if @attack_time >= ATTACK_TIME
        @attacking = false
      end

      @animation.update(LibRay.get_frame_time)

      attack(entities.select(&.is_a?(LivingEntity)).map(&.as(LivingEntity)))
    end
  end
end
