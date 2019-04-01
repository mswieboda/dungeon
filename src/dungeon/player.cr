require "./entity"

module Dungeon
  class Player < Entity
    include DirectionTextures

    property tint : LibRay::Color
    property attacking : Bool
    property attack_time : Int32
    property attack_x : Float32
    property attack_y : Float32
    property attack_rotation : Float32
    property enemy_bump_flash_time : Int32
    property invincible_time : Int32

    FADED = LibRay::Color.new(r: 255, g: 255, b: 255, a: 100)

    PLAYER_MOVEMENT = 200
    TINT_DEFAULT    = LibRay::WHITE

    ATTACK_TIME   = 15
    ATTACK_FRAMES =  5

    ENEMY_BUMP_FLASH_TIME     = 15
    ENEMY_BUMP_FLASH_INTERVAL =  5
    ENEMY_BUMP_FLASH_TINT     = LibRay::RED

    INVINCIBLE_TIME           = 45
    INVINCIBLE_FLASH_INTERVAL = 15
    INVINCIBLE_TINT           = FADED

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @tint = TINT_DEFAULT

      @attacking = false
      @attack_time = 0
      @attack_sprites = [] of LibRay::Texture2D
      @attack_x = @attack_y = @attack_rotation = 0

      @enemy_bump_flash_time = 0
      @invincible_time = 0

      image = LibRay.load_image(File.join(__DIR__, "assets/player-attack.png"))
      @attack_sprite = LibRay.load_texture_from_image(image)
    end

    def texture_file_name
      "player"
    end

    def draw
      if attacking?
        puts "draw: #{y + attack_y}"

        LibRay.draw_texture_pro(
          texture: @attack_sprite,
          source_rec: LibRay::Rectangle.new(
            x: 0,
            y: attack_frame * @attack_sprite.height / ATTACK_FRAMES,
            width: @attack_sprite.width,
            height: @attack_sprite.height / ATTACK_FRAMES
          ),
          dest_rec: LibRay::Rectangle.new(
            x: x + attack_x,
            y: y + attack_y,
            width: @attack_sprite.width,
            height: @attack_sprite.height / ATTACK_FRAMES
          ),
          origin: LibRay::Vector2.new(
            x: @attack_sprite.width / 2,
            y: @attack_sprite.height / ATTACK_FRAMES / 2
          ),
          rotation: attack_rotation,
          tint: tint
        )
      end

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
        draw_collision_box(attack_collision_box) if attacking?
      end
    end

    def attacking?
      attacking
    end

    def attack
      @attack_time = 0
      @attacking = true
    end

    def attack_frame
      (@attack_time / (ATTACK_TIME / ATTACK_FRAMES)).to_i
    end

    def attack_collision_box
      box_x = 0
      box_y = 0
      box_width = 0
      box_height = 0

      if direction.up? || direction.down?
        box_x = attack_x - @attack_sprite.width / 2
        box_y = attack_y - (@attack_sprite.height / ATTACK_FRAMES / 2)
        box_width = @attack_sprite.width
        box_height = @attack_sprite.height / ATTACK_FRAMES
      elsif direction.left? || direction.right?
        box_x = attack_x - (@attack_sprite.height / ATTACK_FRAMES / 2)
        box_y = attack_y - @attack_sprite.width / 2
        box_width = @attack_sprite.height / ATTACK_FRAMES
        box_height = @attack_sprite.width
      end

      Box.new(
        loc: Location.new(box_x, box_y),
        width: box_width,
        height: box_height
      )
    end

    def enemy_bump(enemies)
      enemies.each do |enemy|
        if !invincible? && collision?(enemy)
          # health -= enemy.bump_damage
          @enemy_bump_flash_time = 1
        end
      end
    end

    def invincible?
      enemy_bump_flash_time > 0 || invincible_time > 0
    end

    def movement(entities)
      delta_t = LibRay.get_frame_time
      delta = delta_t * PLAYER_MOVEMENT

      enemies = entities.select { |e| e.is_a?(Enemy) }

      if enemy_bump_flash_time >= ENEMY_BUMP_FLASH_TIME
        @enemy_bump_flash_time = 0
        @tint = TINT_DEFAULT
        @invincible_time = 1
      elsif enemy_bump_flash_time > 0
        @tint = (enemy_bump_flash_time / ENEMY_BUMP_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : ENEMY_BUMP_FLASH_TINT
        @enemy_bump_flash_time += 1
      end

      if invincible_time >= INVINCIBLE_TIME
        @invincible_time = 0
        @tint = TINT_DEFAULT
      elsif invincible_time > 0
        @tint = (invincible_time / INVINCIBLE_FLASH_INTERVAL).to_i % 2 == 1 ? TINT_DEFAULT : INVINCIBLE_TINT
        @invincible_time += 1
      end

      # movement
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

      attack if !attacking? && LibRay.key_pressed?(LibRay::KEY_SPACE)

      # attack timer
      if attacking?
        @attack_time += 1

        if attack_time >= ATTACK_TIME
          @attacking = false
        end
      end

      if attacking?
        @attack_x = @attack_y = @attack_rotation = 0

        if direction.up?
          @attack_y = -height / 2
        elsif direction.down?
          @attack_y = height / 2
          @attack_rotation = 180
        elsif direction.left?
          @attack_x = -width / 2
          @attack_rotation = -90
        elsif direction.right?
          @attack_x = width / 2
          @attack_rotation = 90
        end

        puts "movement: y: #{y} ay: #{attack_y}"

        # TODO: check for collisions with sword with enemies
      end
    end
  end
end
