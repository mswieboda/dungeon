require "./location"

module Dungeon
  class RoomC < Room
    def initialize(game, player)
      width = Game::SCREEN_WIDTH * 3
      height = Game::SCREEN_HEIGHT * 3

      super(game, player, width, height)
    end

    def load
      @entities << @player

      # TODO: move player to start location, change direction, etc

      # walls
      @entities << Wall.new(loc: Location.new(0, 0), width: width, height: 32)

      door_height = 128
      door_width = 32

      @entities << Wall.new(loc: Location.new(width - 32, 0), width: 32, height: height / 4 - door_height)

      door = Door.new(
        loc: Location.new(width - 32, height / 4 - door_height),
        player: @player,
        opening_direction: Direction::Right,
        name: "west",
        next_room_name: RoomB.name,
        next_door_name: "east2"
      )
      @doors << door
      @entities << door

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

      @entities << SoldierMoving.new(loc: Location.new(width - 300, 300))
      @entities << SoldierMoving.new(loc: Location.new(350, height - 350))
      @entities << SoldierMoving.new(loc: Location.new(width / 2 - 400, 400))
      @entities << BasicEnemy.new(loc: Location.new(width / 2 - 600, height / 2 - 600))
      @entities << SoldierFollowing.new(loc: Location.new(width - 675, 500), player: @player, direction: Direction::Down)
      @entities << SoldierGuarding.new(loc: Location.new(200, height - 500), player: @player, direction: Direction::Down)

      super
    end
  end
end
