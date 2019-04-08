require "./enemy"

module Dungeon
  class MovingEnemy < Enemy
    def update(entities)
      super(entities)

      move(entities)

      @moving = true
    end

    def moving?
      @moving
    end

    def move(entities)
      return unless moving?

      player = entities.find(&.is_a?(Player))
      player = player.as(Player) if player

      delta_t = LibRay.get_frame_time

      delta = move_delta(delta_t)
      delta_x = delta[:x]
      delta_y = delta[:y]

      @loc.x += delta_x
      @loc.y += delta_y

      set_direction

      if collidable? && collisions?(entities)
        player_bump_detection(player) if player

        @loc.x -= delta_x
        @loc.y -= delta_y

        move_again
      else
        if move_again?(delta)
          move_again
        else
          stop_moving
        end
      end
    end

    def move_delta(delta_t)
      delta_x = delta_y = 0_f32

      {x: delta_x, y: delta_y}
    end

    def set_direction
      @direction = Direction::Up

      # Note: when subclassing
      # change the animation's direction (usually Animation#row)
      # to match the direction set here
      # if the spritesheet rows match:
      # @animation.row = @direction.value
    end

    def move_again?(delta : NamedTuple(x: Float32, y: Float32))
      true
    end

    def move_again
    end

    def stop_moving
      @moving = false
    end

    def player_bump_detection(player : Player)
      if !invincible? && collision?(player)
        player.enemy_bump(bump_damage)
      end
    end
  end
end
