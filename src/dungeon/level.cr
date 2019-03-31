require "./location"

class Level
  property level_width : Int32
  property level_height : Int32
  property player_location : Location
  property player : Player
  property walls

  DRAW_COLLISION_BOXES = false

  def initialize(@level_width, @level_height)
    @player_location = Location.new(150, 150)
    @player = Player.new(loc: @player_location, width: 48, height: 64)

    @walls = [] of Wall
    walls << Wall.new(loc: Location.new(0, 0), width: level_width, height: 25)
    walls << Wall.new(loc: Location.new(level_width - 25, 0), width: 25, height: level_height)
    walls << Wall.new(loc: Location.new(0, level_height - 25), width: level_width, height: 25)
    walls << Wall.new(loc: Location.new(0, 0), width: 25, height: level_height)
  end

  def draw
    walls.each do |wall|
      wall.draw(DRAW_COLLISION_BOXES)
    end

    @player.draw(DRAW_COLLISION_BOXES)
  end

  def movement
    @player.movement(walls.map { |w| w.collision_rect })
  end
end
