require "./weapon"

module Dungeon
  class Bomb < Weapon
    getter? active
    @bomb_done_frame : Int32

    TIMER = 1

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
      @timer = Timer.new(TIMER)
    end

    def draw
      return unless active?
      super
    end

    def attack
      @active = true
      @timer.restart
    end

    def update(entities)
      return unless active?

      delta_t = LibRay.get_frame_time

      unless attacking?
        @timer.increase(delta_t)

        if @timer.done?
          @timer.reset
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
