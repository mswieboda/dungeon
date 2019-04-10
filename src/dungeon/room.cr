require "./location"

module Dungeon
  class Room
    getter width : Int32
    getter height : Int32
    getter? loaded

    @player : Player

    def initialize(@player, @width = Game::SCREEN_WIDTH, @height = Game::SCREEN_HEIGHT)
      @drawables = [] of Entity
      @entities = [] of Entity
      @doors = [] of Door
      @camera = Camera.new(width: Game::SCREEN_WIDTH, height: Game::SCREEN_HEIGHT)
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

      @entities.each { |entity| entity.update(@entities.reject(entity)) unless entity.removed? }
      @entities.reject!(&.removed?)

      @drawables.concat(@entities)
      @drawables.concat(@player.drawables)

      @drawables.select!(&.viewable?(@camera))

      # change order of drawing based on y coordinates
      @drawables.sort_by! { |d| d.y + d.height }

      @camera.update(@player, width, height)

      @drawables.each(&.update_to_camera(@camera))

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

    def completed?
      enemies = @entities.select(&.is_a?(Enemy))

      enemies.empty?
    end

    def add_entities(entities : Array(Entity))
      @entities += entities
    end
  end
end
