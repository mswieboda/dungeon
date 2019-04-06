require "./weapon"

module Dungeon
  class Bomb < Weapon
    getter? active
    @bomb_done_frame : Int32

    TIMER = 60

    def initialize(loc : Location, direction : Direction)
      sprite = Sprite.get("bomb")

      collision_box = Box.new(
        loc: Location.new(-(sprite.width * 3 / 2), -(sprite.height * 3 / 2)),
        width: sprite.width * 3,
        height: sprite.height * 3
      )

      super(loc, direction, sprite, collision_box: collision_box)

      @bomb_done_frame = @animation.frames

      @active = false
      @timer = 0
    end

    def draw
      return unless active?
      super
    end

    def attack
      @active = true
      @timer = 1
    end

    def update(entities)
      return unless active?

      unless attacking?
        @timer += 1

        if @timer > TIMER
          @timer = 0
          @attacking = true
        end

        return
      end

      if @animation.frame >= @bomb_done_frame - 1
        @active = false
        @attacking = false
      end

      @animation.update(LibRay.get_frame_time)

      attack(entities.select(&.is_a?(LivingEntity)).map(&.as(LivingEntity)))
    end
  end
end
