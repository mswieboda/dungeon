require "cray"
require "./dungeon/*"

module Dungeon
  SCREEN_WIDTH  = 1024
  SCREEN_HEIGHT =  768

  LibRay.init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Dungeon")
  LibRay.set_target_fps(60)

  @@level = Level.new(SCREEN_WIDTH, SCREEN_HEIGHT)

  def self.movement
    @@level.movement
  end

  def self.draw
    LibRay.begin_drawing
    LibRay.clear_background LibRay::BLACK

    @@level.draw

    LibRay.draw_fps(0, 0)

    LibRay.end_drawing
  end

  def self.game_loop
    while !LibRay.window_should_close?
      movement()
      draw()
    end
  end

  def self.run
    game_loop()
    LibRay.close_window
  end
end

Dungeon.run
