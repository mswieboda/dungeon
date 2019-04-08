require "./living_entity"

module Dungeon
  class Player < LivingEntity
    getter bombs_left : Int32
    getter keys_left : Int32
    getter bombs : Array(Bomb)

    @animation : Animation

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200

    INVINCIBLE_TIME           = 32
    INVINCIBLE_FLASH_INTERVAL =  8
    INVINCIBLE_TINT           = FADED

    MAX_HIT_POINTS = 30

    def initialize(loc : Location)
      @direction = Direction::Up

      sprite = Sprite.get("player")

      @animation = Animation.new(sprite)

      width = @animation.width
      height = @animation.height

      collision_box = Box.new(
        loc: Location.new(-12, 16),
        width: 24,
        height: 16
      )

      hit_box = Box.new(
        loc: Location.new(-width / 2, -height / 2),
        width: width,
        height: height
      )

      super(loc, width, height, collision_box, hit_box)

      @animation.tint = @tint
      @animation.row = @direction.value

      @invincible_timer = 0

      @sword = Sword.new(
        loc: Location.new(x + origin.x, y + origin.y),
        direction: @direction
      )

      @bow = Bow.new(
        loc: Location.new(x + origin.x, y + origin.y),
        direction: @direction
      )

      @bombs = [] of Bomb
      @bombs_left = 0
      @keys_left = 0
    end

    def max_hit_points
      MAX_HIT_POINTS
    end

    def tint!(tint : LibRay::Color)
      @tint = tint
      @animation.tint = tint
    end

    def drawables
      drawables = [] of Entity
      drawables.concat(@bombs)
      drawables.concat(@bow.arrows)
      drawables
    end

    def draw
      @sword.draw

      @bow.draw

      @animation.draw(x, y)

      if draw_collision_box?
        draw_collision_box
        draw_hit_box
      end

      draw_hit_points if draw_hit_points?
    end

    def update(entities)
      # living entity
      super

      # flashes
      invincible_flash

      # movement
      move(entities)

      # sword
      @sword.direction = @direction
      @sword.loc = Location.new(x + origin.x, y + origin.y)
      @sword.update(entities)

      @sword.attack if !@sword.attacking? && !invincible? && LibRay.key_pressed?(LibRay::KEY_SPACE)

      # bow and arrows
      @bow.direction = @direction
      @bow.loc = Location.new(x + origin.x, y + origin.y)
      @bow.update(entities)

      @bow.attack if !@bow.attacking? && !invincible? && (LibRay.key_pressed?(LibRay::KEY_LEFT_SHIFT) || LibRay.key_pressed?(LibRay::KEY_RIGHT_SHIFT))

      # bombs
      @bombs.each { |bomb| bomb.update(entities + [self]) }
      @bombs.reject! { |bomb| !bomb.active? }

      if bombs_left? && !invincible? && LibRay.key_pressed?(LibRay::KEY_B)
        @bombs_left -= 1
        bomb = Bomb.new(loc: Location.new(x + origin.x, y + origin.y), direction: @direction)
        bomb.attack
        @bombs << bomb
      end
    end

    def add_bomb
      @bombs_left += 1
    end

    def bombs_left?
      bombs_left > 0
    end

    def arrows_left
      @bow.arrows_left
    end

    def add_arrow
      @bow.add_arrow
    end

    def move(entities)
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
        if collision?(item, item.hit_box)
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

    def key?
      @keys_left > 0
    end

    def add_key
      @keys_left += 1
    end

    def use_key
      @keys_left -= 1
      @keys_left = 0 if @keys_left <= 0
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
