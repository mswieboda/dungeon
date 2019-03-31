require "./location"

class Level
  property level_width : Int32
  property level_height : Int32
  property player_location : Location
  property player : Player
  property drawables
  property collidables

  DRAW_COLLISION_BOXES = true

  def initialize(@level_width, @level_height)
    @drawables = [] of Entity
    @collidables = [] of Entity

    @player_location = Location.new(150, 150)
    @player = Player.new(loc: @player_location, width: 48, height: 64)
    @drawables << @player

    @collidables << Wall.new(loc: Location.new(0, 0), width: level_width, height: 25)
    @collidables << Wall.new(loc: Location.new(level_width - 25, 0), width: 25, height: level_height)
    @collidables << Wall.new(loc: Location.new(0, level_height - 25), width: level_width, height: 25)
    @collidables << Wall.new(loc: Location.new(0, 0), width: 25, height: level_height)

    @enemies = [] of Enemy
    @collidables << Enemy.new(loc: Location.new(300, 300), width: 48, height: 64)

    @drawables += @collidables
  end

  def draw
    @drawables.each { |drawable| drawable.draw(DRAW_COLLISION_BOXES) }
    # @enemies.each { |enemy| enemy.draw(DRAW_COLLISION_BOXES) }

    # @player.draw(DRAW_COLLISION_BOXES)
  end

  def movement
    @player.movement(@collidables.map { |c| c.collision_rect })
  end
end
