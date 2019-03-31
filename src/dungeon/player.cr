require "./entity"

module Dungeon
  class Player < Entity
    include DirectionTextures

    property attacking : Bool
    property attack_time : Int32

    PLAYER_MOVEMENT = 200
    ATTACK_TIME     =  30
    ATTACK_FRAMES   =   5

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @attacking = false
      @attack_time = 0
      @attack_sprites = [] of LibRay::Texture2D

      image = LibRay.load_image(File.join(__DIR__, "assets/player-attack.png"))
      @attack_sprite = LibRay.load_texture_from_image(image)
    end

    def texture_file_name
      "player"
    end

    def draw
      if attacking?
        attack_x = x - width
        attack_y = y - height / 2
        attack_rotation = 0

        if direction.up?
          attack_y -= height / 4
        elsif direction.down?
          attack_y += height / 4
          attack_rotation = 180
        elsif direction.left?
          attack_x -= width / 4
          attack_rotation = -90
        elsif direction.right?
          attack_x += width / 4
          attack_rotation = 90
        end

        LibRay.draw_texture_pro(
          texture: @attack_sprite,
          source_rec: LibRay::Rectangle.new(
            x: 0,
            y: attack_frame * @attack_sprite.height / ATTACK_FRAMES,
            width: @attack_sprite.width,
            height: @attack_sprite.height / ATTACK_FRAMES
          ),
          dest_rec: LibRay::Rectangle.new(
            x: attack_x,
            y: attack_y,
            width: @attack_sprite.width,
            height: @attack_sprite.height / ATTACK_FRAMES
          ),
          origin: LibRay::Vector2.new(
            x: 0,
            y: 0
          ),
          rotation: attack_rotation,
          tint: LibRay::WHITE
        )
      end

      LibRay.draw_texture_v(
        texture: direction_textures[direction.value],
        position: LibRay::Vector2.new(
          x: x - width / 2,
          y: y - height / 2
        ),
        tint: LibRay::WHITE
      )

      draw_collision_box if draw_collision_box?
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

    def movement(collision_rects)
      delta_t = LibRay.get_frame_time
      delta = delta_t * PLAYER_MOVEMENT

      if attacking?
        @attack_time += 1

        if attack_time >= ATTACK_TIME
          @attacking = false
        end
      end

      # movement
      if LibRay.key_down?(LibRay::KEY_W)
        @direction = Direction::Up
        @loc.y -= delta
        @loc.y += delta if collisions?(collision_rects)
      end

      if LibRay.key_down?(LibRay::KEY_A)
        @direction = Direction::Left
        @loc.x -= delta
        @loc.x += delta if collisions?(collision_rects)
      end

      if LibRay.key_down?(LibRay::KEY_S)
        @direction = Direction::Down
        @loc.y += delta
        @loc.y -= delta if collisions?(collision_rects)
      end

      if LibRay.key_down?(LibRay::KEY_D)
        @direction = Direction::Right
        @loc.x += delta
        @loc.x -= delta if collisions?(collision_rects)
      end

      attack if LibRay.key_pressed?(LibRay::KEY_SPACE)
    end
  end
end
