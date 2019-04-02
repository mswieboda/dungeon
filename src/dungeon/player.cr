require "./entity"

module Dungeon
  class Player < Entity
    include DirectionTextures

    property tint : LibRay::Color
    property weapon : Weapon

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200
    TINT_DEFAULT    = LibRay::WHITE

    ENEMY_FLASH_TIME     = 15
    ENEMY_FLASH_INTERVAL =  5
    ENEMY_FLASH_TINT     = LibRay::RED

    INVINCIBLE_TIME           = 45
    INVINCIBLE_FLASH_INTERVAL = 15
    INVINCIBLE_TINT           = FADED

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @tint = TINT_DEFAULT

      @weapon = Weapon.new(loc: loc, direction: @direction, x_offset: width / 2, y_offset: height / 2)

      @enemy_flash_time = 0
      @invincible_time = 0
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

      draw_collision_box if draw_collision_box?
    end

    def enemy_bump(enemies)
      enemies.each do |enemy|
        if !invincible? && collision?(enemy)
          # health -= enemy.bump_damage
          @enemy_flash_time = 1
        end
      end
    end

    def enemy_flash
      if @enemy_flash_time >= ENEMY_FLASH_TIME
        @enemy_flash_time = 0
        @tint = TINT_DEFAULT
        @invincible_time = 1
      elsif @enemy_flash_time > 0
        @tint = (@enemy_flash_time / ENEMY_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : ENEMY_FLASH_TINT
        @enemy_flash_time += 1
      end
    end

    def invincible?
      @enemy_flash_time > 0 || @invincible_time > 0
    end

    def invincible_flash
      if @invincible_time >= INVINCIBLE_TIME
        @invincible_time = 0
        @tint = TINT_DEFAULT
      elsif @invincible_time > 0
        @tint = (@invincible_time / INVINCIBLE_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : INVINCIBLE_TINT
        @invincible_time += 1
      end
    end

    def update(entities)
      enemy_flash()

      invincible_flash()

      movement(entities)

      weapon.direction = direction
      weapon.loc = loc
      weapon.update(entities)
    end

    def movement(entities)
      delta_t = LibRay.get_frame_time
      delta = delta_t * PLAYER_MOVEMENT

      enemies = entities.select { |e| e.is_a?(Enemy) }

      if LibRay.key_down?(LibRay::KEY_W)
        @direction = Direction::Up
        @loc.y -= delta

        enemy_bump(enemies)

        @loc.y += delta if collisions?(entities)
      end

      if LibRay.key_down?(LibRay::KEY_A)
        @direction = Direction::Left
        @loc.x -= delta

        enemy_bump(enemies)

        @loc.x += delta if collisions?(entities)
      end

      if LibRay.key_down?(LibRay::KEY_S)
        @direction = Direction::Down
        @loc.y += delta

        enemy_bump(enemies)

        @loc.y -= delta if collisions?(entities)
      end

      if LibRay.key_down?(LibRay::KEY_D)
        @direction = Direction::Right
        @loc.x += delta

        enemy_bump(enemies)

        @loc.x -= delta if collisions?(entities)
      end
    end
  end
end
