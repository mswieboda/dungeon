module Dungeon
  class Weapon < Entity
    property direction : Direction
    getter? attacking

    ATTACK_TIME   = 15
    ATTACK_FRAMES =  5

    SWORD_DAMAGE = 5

    def initialize(loc : Location, @direction : Direction, @name : Symbol)
      image = LibRay.load_image(File.join(__DIR__, "assets/#{name}-attack.png"))
      @attack_sprite = LibRay.load_texture_from_image(image)

      width = @attack_sprite.width.to_f32
      height = (@attack_sprite.height / ATTACK_FRAMES).to_f32
      collision_box = Box.new(loc: Location.new(0, 0), width: width, height: height)

      super(loc, width, height, collision_box)

      @attacking = false
      @attack_time = 0
      @attack_sprites = [] of LibRay::Texture2D
      @attack_x = @attack_y = @attack_rotation = 0_f32
    end

    def draw
      return unless attacking?

      LibRay.draw_texture_pro(
        texture: @attack_sprite,
        source_rec: LibRay::Rectangle.new(
          x: 0,
          y: attack_frame * height,
          width: width,
          height: height
        ),
        dest_rec: LibRay::Rectangle.new(
          x: x + @attack_x,
          y: y + @attack_y,
          width: width,
          height: height
        ),
        origin: LibRay::Vector2.new(
          x: width / 2,
          y: height / 2
        ),
        rotation: @attack_rotation,
        tint: tint
      )

      draw_collision_box if draw_collision_box?
    end

    def attack
      @attack_time = 0
      @attacking = true
    end

    def attack_frame
      (@attack_time / (ATTACK_TIME / ATTACK_FRAMES)).to_i
    end

    def update(entities)
      attack if !attacking? && LibRay.key_pressed?(LibRay::KEY_SPACE)
      return unless attacking?

      # timer
      @attack_time += 1

      if @attack_time >= ATTACK_TIME
        @attacking = false
      end

      adjust_location_and_dimensions

      # TODO: cast to Enemy
      # map(&.as(ChildClass)
      attack_enemies(entities.select { |e| e.is_a?(Enemy) }.map(&.as(Enemy)))
    end

    def adjust_location_and_dimensions
      @attack_x = @attack_y = @attack_rotation = 0

      if direction.up?
        @attack_y = -height / 2
      elsif direction.down?
        @attack_y = height / 2
        @attack_rotation = 180
      elsif direction.left?
        @attack_x = -width / 2

        # Note: specific sword offset
        @attack_y = -height / 2

        @attack_rotation = -90
      elsif direction.right?
        @attack_x = width / 2

        # Note: specific sword offset
        @attack_y = -height / 2

        @attack_rotation = 90
      end

      # change collision box based on direction
      box_x = 0
      box_y = 0
      box_width = 0
      box_height = 0

      if direction.up? || direction.down?
        box_x = @attack_x - width / 2
        box_y = @attack_y - (height / 2)
        box_width = width
        box_height = height
      elsif direction.left? || direction.right?
        box_x = @attack_x - (height / 2)
        box_y = @attack_y - width / 2
        box_width = height
        box_height = width
      end

      # change weapon loc, and collision_box
      @collision_box.tap do |box|
        box.x = box_x.to_f32
        box.y = box_y.to_f32
        box.width = box_width.to_f32
        box.height = box_height.to_f32
      end
    end

    def attack_enemies(enemies : Array(Enemy))
      enemies.each do |enemy|
        if collision?(enemy)
          enemy.hit(SWORD_DAMAGE)
        end
      end
    end
  end
end
