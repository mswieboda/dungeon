require "./location"

module Dungeon
  class Room
    getter width : Int32
    getter height : Int32
    getter? loaded

    @player : Player

    def initialize(@game : Game, @player, @width = Game::SCREEN_WIDTH, @height = Game::SCREEN_HEIGHT)
      @drawables = [] of Entity
      @entities = [] of Entity
      @doors = [] of Door
      @camera = Camera.new(width: Game::SCREEN_WIDTH, height: Game::SCREEN_HEIGHT)
      @loaded = false
    end

    def load
      # initialize room entities, etc
    end

    def start
      # ran once the room is loaded, and first update and draw ran
    end

    def draw
      @drawables.each(&.draw)
    end

    def update
      @drawables.clear

      @entities.each { |entity| entity.update(@entities.reject(entity)) unless entity.removed? }
      @entities.reject!(&.removed?)

      @drawables.concat(@entities.select(&.viewable?(@camera)))
      @drawables.concat(@player.drawables)

      # change order of drawing based on y coordinates
      sort_drawables

      @camera.update(@player, width, height)

      @drawables.each(&.update_to_camera(@camera))

      @doors.each(&.open) if completed?

      return if loaded?

      start

      @loaded = true
    end

    def sort_drawables
      drawables = @drawables.select(&.bottom_layer?)
      drawables.concat(@drawables.reject(&.bottom_layer?).sort_by! { |d| d.y + d.height })
      @drawables = drawables
    end

    def change_room
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
