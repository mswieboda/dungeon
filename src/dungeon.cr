require "cray"
require "./dungeon/*"

module Dungeon
  def self.run
    Game.new.run
  end
end

Dungeon.run
