require "./location"

class Level
  property level_width : Int32
  property level_height : Int32
  property player_location : Location
  property player : Player
  property walls

  def initialize(@level_width, @level_height)
    @player_location = Location.new(10, 50)
    @player = Player.new(x: level_width / 2_f32, y: level_height / 2_f32, height: 50, width: 30, rotation: 0)

    @walls = [] of Wall
    walls << Wall.new(Location.new(100, 100), 10, 100, 1)
    walls << Wall.new(Location.new(200, 300), 10, 100, 2)
  end

  def draw
    walls.each do |wall|
      wall.draw
    end

    @player.draw
  end

  def movement
    @player.movement
  end
end
