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

      @left_room = false

      # load sprites
      keys_sprite = Sprite.get("items/keys")

      # player
      @entities << @player

      # walls
      @entities << Wall.new(loc: Location.new(0, 0), width: width, height: 32)

      door_height = 128

      @entities << Wall.new(loc: Location.new(width - 32, 0), width: 32, height: height / 4 - door_height)

      @door = Door.new(loc: Location.new(width - 32, height / 4 - door_height), width: 32, height: door_height, player: @player)
      @entities << @door

      @entities << Wall.new(loc: Location.new(width - 32, height / 4), width: 32, height: height - height / 4)

      @entities << Wall.new(loc: Location.new(0, height - 32), width: width, height: 32)
      @entities << Wall.new(loc: Location.new(0, 0), width: 32, height: height)
      @entities << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # items
      @entities << FullHeart.new(loc: Location.new(200, 150), player: @player)
      @entities << HalfHeart.new(loc: Location.new(250, 150), player: @player)
      @entities << Key.new(loc: Location.new(300, 150), player: @player)
      @entities << BombItem.new(loc: Location.new(350, 150), player: @player)
      @entities << ArrowItem.new(loc: Location.new(400, 150), player: @player)
      @entities << Chest.new(loc: Location.new(400, 300), room: self, player: @player)
      @entities << LockedChest.new(loc: Location.new(400, 75), room: self, player: @player)

      # enemies
      @entities << SoldierMoving.new(loc: Location.new(300, 300))
      @entities << SoldierMoving.new(loc: Location.new(350, 350))
      @entities << SoldierMoving.new(loc: Location.new(400, 400))
      @entities << BasicEnemy.new(loc: Location.new(600, 600))
      @entities << SoldierFollowing.new(loc: Location.new(675, 500), player: @player, direction: Direction::Down)
      @entities << SoldierGuarding.new(loc: Location.new(200, 500), player: @player, direction: Direction::Down)
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
