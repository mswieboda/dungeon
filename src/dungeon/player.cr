require "./living_entity"

module Dungeon
  class Player < LivingEntity
    getter bombs_left : Int32
    getter keys_left : Int32
    getter bombs : Array(Bomb)

    property direction : Direction

    @animation : Animation

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200

    INVINCIBLE_TIME           = 0.5
    INVINCIBLE_FLASHES        =   2
    INVINCIBLE_FLASH_INTERVAL = INVINCIBLE_TIME / INVINCIBLE_FLASHES / 2
    INVINCIBLE_TINT           = FADED

    MAX_HIT_POINTS = 30

    def initialize
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

      super(Location.new, width, height, collision_box, hit_box)

      @animation.tint = @tint
      @animation.row = @direction.value

      @invincible_timer = Timer.new(INVINCIBLE_TIME)

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

      @animation.draw(@screen_x, @screen_y)

      if draw_collision_box?
        draw_collision_box
        draw_hit_box
      end

      draw_hit_points if draw_hit_points?
    end

    def updates_to_camera(camera : Camera)
      @sword.update_to_camera(camera)
      @bow.update_to_camera(camera)
      @bombs.each(&.update_to_camera(camera))
    end

    def update(entities)
      # living entity
      super

      delta_t = LibRay.get_frame_time

      # flashes
      invincible_flash(delta_t)

      # movement
      move(entities)

      # sword
      @sword.direction = @direction
      @sword.update_loc(loc, origin, collision_box, width, height)
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
      delta = delta_t * PLAYER_MOVEMENT

      collidables = entities.select(&.collidable?)
      bumpables = entities.select(&.responds_to?(:bump_damage))

      items = entities.select(&.is_a?(Item)).map(&.as(Item))

      if LibRay.key_down?(LibRay::KEY_W)
        unless @sword.attacking?
          @direction = Direction::Up
          @animation.row = @direction.value
        end

        @loc.y -= delta

        bump_detections(bumpables)

        @loc.y += delta if collisions?(collidables)
      end

      if LibRay.key_down?(LibRay::KEY_A)
        unless @sword.attacking?
          @direction = Direction::Left
          @animation.row = @direction.value
        end

        @loc.x -= delta

        bump_detections(bumpables)

        @loc.x += delta if collisions?(collidables)
      end

      if LibRay.key_down?(LibRay::KEY_S)
        unless @sword.attacking?
          @direction = Direction::Down
          @animation.row = @direction.value
        end

        @loc.y += delta

        bump_detections(bumpables)

        @loc.y -= delta if collisions?(collidables)
      end

      if LibRay.key_down?(LibRay::KEY_D)
        unless @sword.attacking?
          @direction = Direction::Right
          @animation.row = @direction.value
        end

        @loc.x += delta

        bump_detections(bumpables)

        @loc.x -= delta if collisions?(collidables)
      end

      items.each do |item|
        if collision?(item, item.hit_box)
          pick_up(item)
        end
      end
    end

    def bump_detections(entities : Array(Entity))
      return if invincible?

      entities.each do |entity|
        if collision?(entity)
          bump_damage = entity.bump_damage
          bump(bump_damage) if bump_damage
        end
      end
    end

    def bump(damage)
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
      super

      @invincible_timer.start unless @death_timer.active? || dead?
    end

    def invincible_flash(delta_t)
      if @invincible_timer.done?
        @invincible_timer.reset
        tint!(TINT_DEFAULT)
      elsif @invincible_timer.active?
        tint = (@invincible_timer.time / INVINCIBLE_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : INVINCIBLE_TINT
        tint!(tint)
        @invincible_timer.increase(delta_t)
      end
    end

    def invincible?
      super || @invincible_timer.active?
    end

    def collidable?
      true
    end
  end
end
