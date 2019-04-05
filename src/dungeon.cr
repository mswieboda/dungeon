require "cray"
require "./dungeon/*"

module Dungeon
  def self.run
    game = Game.new
    game.run
  end
end

Dungeon.run
