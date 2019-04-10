require "./entity"

module Dungeon
  class LivingEntity < Entity
    getter hit_points
    getter tint_default : LibRay::Color
    getter? dead

    HIT_FLASH_TIME     = 32
    HIT_FLASH_INTERVAL =  8
    HIT_FLASH_TINT     = LibRay::RED

    DEATH_TIME = 1

    MAX_HIT_POINTS  = 15
    DRAW_HIT_POINTS = Game::DEBUG

    def initialize(loc : Location, width, height, collision_box : Box, @hit_box : Box, @tint_default = TINT_DEFAULT)
      super(loc, width, height, collision_box, hit_box, tint_default)

      @hit_flash_timer = 0

      @hit_points = max_hit_points
      @death_timer = Timer.new(DEATH_TIME)
      @dead = false
    end

    def tint!(tint : LibRay::Color)
      @tint = tint
    end

    def max_hit_points
      MAX_HIT_POINTS
    end

    def max_hit_points?
      @hit_points >= max_hit_points
    end

    def draw_hit_points
      color = LibRay::GREEN

      red = 0
      green = 255
      blue = 0
      alpha = 255

      # green -> yellow -> red
      if @hit_points >= max_hit_points / 2
        red = (255 * max_hit_points / @hit_points) - 255
        green = 255
      elsif @hit_points < max_hit_points / 2
        red = 255
        green = 255 * @hit_points / max_hit_points * 2
      end

      color = LibRay::Color.new(r: red, g: green, b: blue, a: alpha)

      LibRay.draw_text(
        text: @hit_points.to_s,
        pos_x: @screen_x,
        pos_y: @screen_y - height / 1.5,
        font_size: 20,
        color: color
      )
    end

    def draw_hit_points?
      DRAW_HIT_POINTS
    end

    def update(_entities)
      hit_flash
      death_fade
    end

    def hit_flash
      if @hit_flash_timer >= HIT_FLASH_TIME
        @hit_flash_timer = 0
        tint!(tint_default)

        after_hit_flash
      elsif @hit_flash_timer > 0
        tint = (@hit_flash_timer / HIT_FLASH_INTERVAL).to_i % 2 == 1 ? tint_default : HIT_FLASH_TINT
        tint!(tint)
        @hit_flash_timer += 1
      end
    end

    def after_hit_flash
    end

    def death_fade
      if @death_timer.done?
        @death_timer.reset
        @dead = true
      elsif @death_timer.active?
        tint = tint_default
        tint.a = 255 - 255 * @death_timer.percentage
        tint!(tint)
        @death_timer.increase(LibRay.get_frame_time)
      end
    end

    def hit(damage = 0)
      return if invincible?

      @hit_flash_timer = 1
      @hit_points -= damage

      die if @hit_points <= 0
    end

    def die
      @hit_points = 0
      @death_timer.start
    end

    def invincible?
      @hit_flash_timer > 0 || @death_timer.active? || dead?
    end

    def heal(hit_points)
      @hit_points += hit_points

      # TODO: some green flash animation if healed?

      @hit_points = max_hit_points if @hit_points > max_hit_points
    end

    def removed?
      dead?
    end
  end
end
