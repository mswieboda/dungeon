require "./entity"

module Dungeon
  class Player < Entity
    include DirectionTextures

    property attacking : Bool
    property attack_frame : Int32

    PLAYER_MOVEMENT = 200
    ATTACK_FRAMES   =   5

    def initialize(@loc : Location, @width : Float32, @height : Float32, @collision_box : Box)
      super

      @direction = Direction::Up
      @direction_textures = [] of LibRay::Texture2D
      load_textures

      @attacking = false
      @attack_frame = 0
      @attack_sprites = [] of LibRay::Texture2D

      ATTACK_FRAMES.times do |index|
        image = LibRay.load_image(File.join(__DIR__, "assets/player-attack-#{index}.png"))
        @attack_sprites << LibRay.load_texture_from_image(image)
      end
    end

    def texture_file_name
      "player"
    end

    def draw
      LibRay.draw_texture_v(
        texture: direction_textures[direction.value],
        position: LibRay::Vector2.new(
          x: x - width / 2,
          y: y - height / 2
        ),
        tint: LibRay::WHITE
      )

      if attacking?
        # puts "attacking draw"
        # rect = LibRay::Rectangle.new
        # rect.x = 0_f32
        # rect.y = 0_f32
        # rect.width = @attack_sprite.width.to_f32
        # rect.height = @attack_sprite.height / 2_f32

        # puts rect

        # LibRay.draw_texture_rec(
        #   texture: @attack_sprite,
        #   source_rec: rect,
        #   position: LibRay::Vector2.new(
        #     x: x,
        #     y: y - 64
        #   ),
        #   tint: LibRay::WHITE
        # )

        LibRay.draw_texture_v(
          texture: @attack_sprites[attack_frame],
          position: LibRay::Vector2.new(
            x: x,
            y: y - 64
          ),
          tint: LibRay::WHITE
        )
      end

      draw_collision_box if draw_collision_box?
    end

    def attacking?
      attacking
    end

    def attack
      puts "attack"
      @attack_frame = 0
      @attacking = true
    end

    def movement(collision_rects)
      delta_t = LibRay.get_frame_time
      delta = delta_t * PLAYER_MOVEMENT

      if attacking?
        puts "attacking timer"
        @attack_frame += 1

        if attack_frame >= ATTACK_FRAMES
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

      if LibRay.key_pressed?(LibRay::KEY_SPACE)
        puts "space"
        attack
      end
    end
  end
end
