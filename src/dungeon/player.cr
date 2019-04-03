require "./living_entity"

module Dungeon
  class Player < LivingEntity
    include DirectionTextures

    getter weapon : Weapon

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200

    INVINCIBLE_TIME           = 45
    INVINCIBLE_FLASH_INTERVAL = 15
    INVINCIBLE_TINT           = FADED

    def initialize(loc : Location, collision_box : Box)
      # TODO: switch this to sprite sheet
      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      width = @direction_textures[@direction.value].width
      height = @direction_textures[@direction.value].height

      super(loc, width, height, collision_box)

      @weapon = Weapon.new(
        loc: Location.new(x + origin.x, y + origin.y),
        direction: @direction,
        name: :sword
      )

      @invincible_timer = 0
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
      draw_hit_points if draw_hit_points?
    end

    def update(entities)
      super

      invincible_flash

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

    def enemy_bump_detections(enemies : Array(Enemy))
      enemies.each do |enemy|
        enemy_bump(enemy.bump_damage) if collision?(enemy)
      end
    end

    def enemy_bump(damage)
      hit(damage)
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

    def invincible?
      super || @invincible_timer > 0
    end

    def removed?
      dead?
    end
  end
end
