require "./weapon"

module Dungeon
  class Bow < Weapon
    property arrows_left : Int32
    getter arrows : Array(Arrow)

    HOLD_TIME = 0.75

    def initialize(loc : Location, direction : Direction)
      sprite = Sprite.get("bow")

      collision_box = Box.new(
        loc: Location.new(-sprite.width / 2, -sprite.height / 2),
        width: sprite.width,
        height: sprite.height
      )

      super(loc, direction, sprite, collision_box: collision_box)

      @animation.fps = 6

      @arrows = [] of Arrow
      @arrows_left = 100

      @hold_timer = 0_f32

      @attack_x = @attack_y = 0
    end

    def direction=(direction)
      @direction = direction
      adjust_location_and_dimensions
    end

    def draw
      @arrows.each(&.draw)

      return unless attacking?

      @animation.draw(x + @attack_x, y + @attack_y)

      draw_hold_bar if draw_collision_box?

      draw_collision_box if draw_collision_box?
    end

    def draw_hold_bar
      box_width = (width / 2) * (@hold_timer / HOLD_TIME)
      color = @hold_timer >= HOLD_TIME ? LibRay::GREEN : LibRay::RED

      LibRay.draw_rectangle(
        pos_x: x - box_width / 2,
        pos_y: y + 10,
        width: box_width,
        height: 5,
        color: color
      )
    end

    def attack
      return unless arrows_left?

      @attacking = true
    end

    def arrows_left?
      arrows_left > 0
    end

    def add_arrow
      @arrows_left += 1
    end

    def update(entities)
      @arrows.each { |arrow| arrow.update(entities) }
      @arrows.reject! { |arrow| !arrow.active? }

      return unless attacking?

      delta_t = LibRay.get_frame_time

      if @hold_timer >= HOLD_TIME
        fire if LibRay.key_up?(LibRay::KEY_LEFT_SHIFT) && LibRay.key_up?(LibRay::KEY_RIGHT_SHIFT)
      elsif LibRay.key_down?(LibRay::KEY_LEFT_SHIFT) || LibRay.key_down?(LibRay::KEY_RIGHT_SHIFT)
        @hold_timer += delta_t
        @animation.update(delta_t) unless @animation.frame + 1 >= @animation.frames
      else
        restart_attack
      end
    end

    def adjust_location_and_dimensions
      @attack_x = @attack_y = 0

      if direction.up?
        @attack_y = -height / 3
        @animation.rotation = 90
      elsif direction.down?
        @animation.rotation = -90
      elsif direction.left?
        @attack_x = -width / 8
        @attack_y = -height / 4
        @animation.rotation = 0
      elsif direction.right?
        @attack_x = width / 8
        @attack_y = -height / 4
        @animation.rotation = 180
      end
    end

    def restart_attack
      @attacking = false
      @hold_timer = 0
      @animation.restart
    end

    def fire
      return unless arrows_left?

      restart_attack

      @arrows_left -= 1

      arrow = Arrow.new(
        loc: Location.new(x, y),
        direction: direction
      )

      @arrows << arrow
    end
  end
end
