module Dungeon
  class Weapon < Entity
    getter direction : Direction
    getter? attacking

    @animation : Animation

    ATTACK_TIME = 16

    SWORD_DAMAGE = 5

    def initialize(loc : Location, @direction : Direction, sprite)
      @animation = Animation.new(
        sprite: sprite,
        row: 0,
        fps: ATTACK_TIME
      )

      width = @animation.width
      height = @animation.height

      collision_box = Box.new(loc: Location.new(0, 0), width: width, height: height)

      super(loc, width, height, collision_box)

      @animation.tint = @tint

      @attacking = false
      @attack_time = 0
      # @attack_sprites = [] of LibRay::Texture2D
      @attack_x = @attack_y = @attack_rotation = 0_f32
    end

    def draw
      return unless attacking?

      @animation.draw(x + @attack_x, y + @attack_y)

      draw_collision_box if draw_collision_box?
    end

    def direction=(direction)
      @direction = direction
      adjust_location_and_dimensions
    end

    def attack
      @attack_time = 0
      @animation.restart!
      @attacking = true
    end

    def update(entities)
      return unless attacking?

      # timer
      @attack_time += 1

      if @attack_time >= ATTACK_TIME
        @attacking = false
      end

      adjust_location_and_dimensions

      @animation.update(LibRay.get_frame_time) if attacking?

      attack_enemies(entities.select(&.is_a?(Enemy)).map(&.as(Enemy)))
    end

    def adjust_location_and_dimensions
      @attack_x = @attack_y = @attack_rotation = 0

      if direction.up?
        @attack_y = -height / 2
        @animation.row = 0
        @animation.rotation = 0
      elsif direction.down?
        @attack_y = height / 2
        @animation.row = 0
        @animation.rotation = 180
      elsif direction.left?
        @attack_x = -width / 2

        # Note: specific sword offset
        @attack_y = -height / 2

        @animation.row = 1
        @animation.rotation = 180
      elsif direction.right?
        @attack_x = width / 2

        # Note: specific sword offset
        @attack_y = -height / 2

        @animation.row = 1
        @animation.rotation = 0
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
