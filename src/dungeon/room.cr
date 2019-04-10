require "./location"

module Dungeon
  class Room
    getter width : Int32
    getter height : Int32
    getter? loaded

    @camera_x : Int32
    @camera_y : Int32

    @player : Player

    def initialize(@player, @width = Game::SCREEN_WIDTH, @height = Game::SCREEN_HEIGHT)
      @drawables = [] of Entity
      @entities = [] of Entity
      @doors = [] of Door
      @camera_x = @camera_y = 0
      @camera_width = Game::SCREEN_WIDTH
      @camera_height = Game::SCREEN_HEIGHT
    end

    def load_initial
      # initialize room entities, etc
      @loaded = true
    end

    def draw
      @drawables.each(&.draw)
    end

    def update
      @drawables.clear

      update_camera

      @entities.each { |entity| entity.update(@entities.reject(entity)) unless entity.removed? }
      @entities.reject!(&.removed?)

      @drawables.concat(@entities)
      @drawables.concat(@player.drawables)

      @drawables.reject! { |d| !viewable?(d) }

      # change order of drawing based on y coordinates
      @drawables.sort_by! { |d| d.y + d.height }

      update_drawables_to_camera

      @doors.each(&.open) if completed?
    end

    def room_change
      @doors.each do |door|
        return door.pass_through if door.passed_through?
      end
    end

    def get_door(next_door_name : String)
      @doors.find { |door| door.name == next_door_name }
    end

    def update_camera
      @camera_x = (@player.x - @camera_width / 2).clamp(0, width - @camera_width).to_i
      @camera_y = (@player.y - @camera_height / 2).clamp(0, height - @camera_height).to_i
    end

    def viewable?(entity : Entity)
      entity.x + entity.width >= @camera_x && entity.x <= @camera_x + @camera_width &&
        entity.y + entity.height >= @camera_y && entity.y <= @camera_y + @camera_height
    end

    def update_drawables_to_camera
      @drawables.each do |d|
        d.update_to_camera(@camera_x, @camera_y)
      end
    end

    def completed?
      enemies = @entities.select(&.is_a?(Enemy))

      enemies.empty?
    end

    def add_entities(entities : Array(Entity))
      @entities += entities
    end
  end
end
