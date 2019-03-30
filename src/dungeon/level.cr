require "./location"

class Level
  property level_width : Int32
  property level_height : Int32
  property player_location : Location
  property player : Player
  property walls

  def initialize(@level_width, @level_height)
    @player_location = Location.new(10, 50)
    @player = Player.new(loc: @player_location, width: 48, height: 64)

    @walls = [] of Wall
    walls << Wall.new(Location.new(500, 100), 10, 100, 1)
    walls << Wall.new(Location.new(300, 300), 10, 100, 2)
  end

  def draw
    walls.each do |wall|
      wall.draw
    end

    @player.draw
  end

  def movement
    @player.movement(walls.map { |w| w.collision_rect })
  end
end
