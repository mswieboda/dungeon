require "./enemy"

module Dungeon
  class SoldierGuarding < SoldierFollowing
    @line_of_site_box : Box
    @original_target : Hash(Symbol, Float32)
    @target : Hash(Symbol, Float32)

    MOVEMENT = 50

    def initialize(loc : Location, player : Player, direction = Direction::Up)
      super(loc, player, direction)

      @original_target = {:x => x, :y => y}
    end

    def set_target
      @target = @original_target
    end
  end
end
