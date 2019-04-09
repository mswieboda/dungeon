require "./location"

module Dungeon
  class Room
    getter? left_room
    getter width : Int32
    getter height : Int32

    @player : Player
    @door : Door

    def initialize(@player, screenWidth, screenHeight)
      @width = screenWidth
      @height = screenHeight

      @drawables = [] of Entity
      @entities = [] of Entity

      door_height = 128
      @door = Door.new(loc: Location.new(width - 32, height / 4 - door_height), width: 32, height: door_height, player: @player)

      @left_room = false

      load_initial
    end

    def load_initial
      # initialize room entities, etc
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

      # change order of drawing based on y coordinates
      @drawables.sort_by! { |d| d.y + d.height }

      @door.open if completed?
      leave_room if @door.passed_through?
    end

    def completed?
      enemies = @entities.select(&.is_a?(Enemy))

      enemies.empty?
    end

    def add_entities(entities : Array(Entity))
      @entities += entities
    end

    def leave_room
      @left_room = true
    end
  end
end
