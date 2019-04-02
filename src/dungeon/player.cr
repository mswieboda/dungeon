require "./entity"

module Dungeon
  class Player < Entity
    include DirectionTextures

    getter origin
    getter tint : LibRay::Color
    getter weapon : Weapon
    getter? dead

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200
    TINT_DEFAULT    = LibRay::WHITE

    HIT_FLASH_TIME     = 15
    HIT_FLASH_INTERVAL =  5
    HIT_FLASH_TINT     = LibRay::RED

    INVINCIBLE_TIME           = 45
    INVINCIBLE_FLASH_INTERVAL = 15
    INVINCIBLE_TINT           = FADED

    DEATH_TIME = 150

    MAX_HIT_POINTS  = 15
    DRAW_HIT_POINTS = true

    BUMP_DAMAGE = 5

    def initialize(@loc : Location, @origin : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super(@loc, @width, @height, @collision_box)

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @tint = TINT_DEFAULT

      # @weapon = Weapon.new(loc: loc, direction: @direction, x_offset: width / 2, y_offset: height / 2)
      @weapon = Weapon.new(loc: origin, direction: @direction)

      @hit_flash_timer = 0
      @invincible_timer = 0

      @hit_points = MAX_HIT_POINTS
      @death_timer = 0
      @dead = false
    end

    def texture_file_name
      "player"
    end

    def draw
      weapon.draw

      LibRay.draw_texture_v(
        texture: direction_textures[direction.value],
        position: LibRay::Vector2.new(
          x: x - width / 2,
          y: y - height / 2
        ),
        tint: tint
      )

      if draw_collision_box?
        draw_collision_box

        # draw origin
        line_size = 5

        # x line
        LibRay.draw_line_bezier(
          start_pos: LibRay::Vector2.new(x: x + origin.x + line_size, y: y + origin.y),
          end_pos: LibRay::Vector2.new(x: x + origin.x - line_size, y: y + origin.y),
          thick: 1,
          color: LibRay::MAGENTA
        )

        # y line
        LibRay.draw_line_bezier(
          start_pos: LibRay::Vector2.new(x: x + origin.x, y: y + origin.y + line_size),
          end_pos: LibRay::Vector2.new(x: x + origin.x, y: y + origin.y - line_size),
          thick: 1,
          color: LibRay::MAGENTA
        )
      end
      draw_hit_points if DRAW_HIT_POINTS
    end

    def draw_hit_points
      color = LibRay::GREEN

      red = 0
      green = 255
      blue = 0
      alpha = 255

      # green -> yellow -> red
      if @hit_points >= MAX_HIT_POINTS / 2
        red = (255 * MAX_HIT_POINTS / @hit_points) - 255
        green = 255
      elsif @hit_points < MAX_HIT_POINTS / 2
        red = 255
        green = 255 * @hit_points / MAX_HIT_POINTS * 2
      end

      color = LibRay::Color.new(r: red, g: green, b: blue, a: alpha)

      LibRay.draw_text(
        text: @hit_points.to_s,
        pos_x: x,
        pos_y: y - height / 1.5,
        font_size: 20,
        color: color
      )
    end

    def update(entities)
      hit_flash
      invincible_flash
      death_fade

      movement(entities)

      weapon.direction = direction
      weapon.loc = Location.new(x + origin.x, y + origin.y)
      weapon.update(entities)
    end

    def movement(entities)
      delta_t = LibRay.get_frame_time
      speed = delta_t * PLAYER_MOVEMENT

      enemies = entities.select(&.is_a?(Enemy)).map(&.as(Enemy))

      if LibRay.key_down?(LibRay::KEY_W)
        @direction = Direction::Up
        @loc.y -= speed

        enemy_bump_detections(enemies)

        @loc.y += speed if collisions?(entities)
      end

      if LibRay.key_down?(LibRay::KEY_A)
        @direction = Direction::Left
        @loc.x -= speed

        enemy_bump_detections(enemies)

        @loc.x += speed if collisions?(entities)
      end

      if LibRay.key_down?(LibRay::KEY_S)
        @direction = Direction::Down
        @loc.y += speed

        enemy_bump_detections(enemies)

        @loc.y -= speed if collisions?(entities)
      end

      if LibRay.key_down?(LibRay::KEY_D)
        @direction = Direction::Right
        @loc.x += speed

        enemy_bump_detections(enemies)

        @loc.x -= speed if collisions?(entities)
      end
    end

    def hit_flash
      if @hit_flash_timer >= HIT_FLASH_TIME
        @hit_flash_timer = 0
        @tint = TINT_DEFAULT
        @invincible_timer = 1
      elsif @hit_flash_timer > 0
        @tint = (@hit_flash_timer / HIT_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : HIT_FLASH_TINT
        @hit_flash_timer += 1
      end
    end

    def invincible_flash
      if @invincible_timer >= INVINCIBLE_TIME
        @invincible_timer = 0
        @tint = TINT_DEFAULT
      elsif @invincible_timer > 0
        @tint = (@invincible_timer / INVINCIBLE_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : INVINCIBLE_TINT
        @invincible_timer += 1
      end
    end

    def death_fade
      if @death_timer >= DEATH_TIME
        @death_timer = 0
        @dead = true
      elsif @death_timer > 0
        @tint = TINT_DEFAULT
        @tint.a = 255 - 255 * @death_timer / DEATH_TIME
        @death_timer += 1
      end
    end

    def enemy_bump_detections(enemies : Array(Enemy))
      enemies.each do |enemy|
        enemy_bump(enemy.bump_damage) if collision?(enemy)
      end
    end

    def enemy_bump(damage = BUMP_DAMAGE)
      hit(damage)
    end

    def invincible?
      @hit_flash_timer > 0 || @invincible_timer > 0
    end

    def hit(damage = 0)
      return if invincible?

      @hit_flash_timer = 1
      @hit_points -= damage

      die if @hit_points <= 0
    end

    def die
      @hit_points = 0
      @death_timer = 1
    end

    def removed?
      dead?
    end
  end
end
