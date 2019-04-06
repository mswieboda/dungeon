require "./living_entity"

module Dungeon
  class Player < LivingEntity
    @animation : Animation

    getter weapon : Weapon

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200

    INVINCIBLE_TIME           = 32
    INVINCIBLE_FLASH_INTERVAL =  8
    INVINCIBLE_TINT           = FADED

    MAX_HIT_POINTS = 30

    def initialize(loc : Location, collision_box : Box, sprite : LibRay::Texture2D, weapon_sprite : LibRay::Texture2D)
      @direction = Direction::Up

      @animation = Animation.new(
        sprite: sprite,
        frames: 1,
        rows: 4,
        row: 0
      )

      width = @animation.width
      height = @animation.height

      super(loc, width, height, collision_box)

      @animation.tint = @tint
      @animation.row = @direction.value

      @weapon = Weapon.new(
        loc: Location.new(x + origin.x, y + origin.y),
        direction: @direction,
        sprite: weapon_sprite
      )

      @invincible_timer = 0
    end

    def max_hit_points
      MAX_HIT_POINTS
    end

    def tint!(tint : LibRay::Color)
      @tint = tint
      @animation.tint = tint
    end

    def draw
      weapon.draw

      @animation.draw(x, y)

      draw_collision_box if draw_collision_box?
      draw_hit_points if draw_hit_points?
    end

    def update(entities)
      super

      invincible_flash

      movement(entities)

      weapon.direction = @direction
      weapon.loc = Location.new(x + origin.x, y + origin.y)
      weapon.update(entities)

      weapon.attack if !weapon.attacking? && !invincible? && LibRay.key_pressed?(LibRay::KEY_SPACE)
    end

    def movement(entities)
      delta_t = LibRay.get_frame_time
      speed = delta_t * PLAYER_MOVEMENT

      collidables = entities.select(&.collidable?)
      enemies = entities.select(&.is_a?(Enemy)).map(&.as(Enemy))
      items = entities.select(&.is_a?(Item)).map(&.as(Item))

      if LibRay.key_down?(LibRay::KEY_W)
        @direction = Direction::Up
        @animation.row = @direction.value
        @loc.y -= speed
      end

      if LibRay.key_down?(LibRay::KEY_A)
        @direction = Direction::Left
        @animation.row = @direction.value
        @loc.x -= speed
      end

      if LibRay.key_down?(LibRay::KEY_S)
        @direction = Direction::Down
        @animation.row = @direction.value
        @loc.y += speed
      end

      if LibRay.key_down?(LibRay::KEY_D)
        @direction = Direction::Right
        @animation.row = @direction.value
        @loc.x += speed
      end

      enemy_bump_detections(enemies)

      if collisions?(collidables)
        if @direction.up?
          @loc.y += speed
        elsif @direction.left?
          @loc.x += speed
        elsif @direction.down?
          @loc.y -= speed
        elsif @direction.right?
          @loc.x -= speed
        end
      end

      items.each do |item|
        if collision?(item)
          pick_up(item)
        end
      end
    end

    def enemy_bump_detections(enemies : Array(Enemy))
      return if invincible?

      enemies.each do |enemy|
        enemy_bump(enemy.bump_damage) if collision?(enemy)
      end
    end

    def enemy_bump(damage)
      hit(damage)
    end

    def pick_up(item : Item)
      item.pick_up
    end

    def after_hit_flash
      @invincible_timer = 1
    end

    def invincible_flash
      if @invincible_timer >= INVINCIBLE_TIME
        @invincible_timer = 0
        tint!(TINT_DEFAULT)
      elsif @invincible_timer > 0
        tint = (@invincible_timer / INVINCIBLE_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : INVINCIBLE_TINT
        tint!(tint)
        @invincible_timer += 1
      end
    end

    def invincible?
      super || @invincible_timer > 0
    end

    def collidable?
      true
    end
  end
end
