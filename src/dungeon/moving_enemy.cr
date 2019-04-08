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
      # easier to call:
      # set_direction_x(delta_x)
      # or
      # set_direction_y(delta_y)
      # to set direction
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

    # helpers for set_direction
    def set_direction_x(delta_x)
      if delta_x > 0_f32
        @direction = Direction::Right
      elsif delta_x < 0_f32
        @direction = Direction::Left
      end
    end

    def set_direction_y(delta_y)
      if delta_y > 0_f32
        @direction = Direction::Down
      elsif delta_y < 0_f32
        @direction = Direction::Up
      end
    end
  end
end
