require "cray"

class Bullet
  property x : Float32
  property y : Float32

  def initialize(@x : Float32, @y : Float32)
  end
end

module CrayTest
  SCREEN_WIDTH  = 1024
  SCREEN_HEIGHT =  768

  LibRay.init_window SCREEN_WIDTH, SCREEN_HEIGHT, "Example: input"

  @@icon = LibRay.load_image File.join(__DIR__, "circle.png")
  @@circle = LibRay.load_texture_from_image(@@icon)

  LibRay.set_window_icon(@@icon)

  @@circle_pos = LibRay::Vector2.new(x: SCREEN_WIDTH/2 - @@circle.width/2, y: SCREEN_HEIGHT/2 - @@circle.height/2)
  @@bullets = [] of Bullet

  SPEED     = 300
  TEXT      = "Use WASD to move the red circle!"
  FONT_SIZE = 20

  def self.input_events
    delta = LibRay.get_frame_time

    if LibRay.key_down? LibRay::KEY_W
      @@circle_pos.y -= delta * SPEED
    end

    if LibRay.key_down? LibRay::KEY_S
      @@circle_pos.y += delta * SPEED
    end

    if LibRay.key_down? LibRay::KEY_A
      @@circle_pos.x -= delta * SPEED
    end

    if LibRay.key_down? LibRay::KEY_D
      @@circle_pos.x += delta * SPEED
    end

    if LibRay.key_released? LibRay::KEY_SPACE
      @@bullets << Bullet.new(x: @@circle_pos.x + (@@circle.width / 2), y: @@circle_pos.y - (@@circle.height / 4))
    end
  end

  def self.movement
    delta = LibRay.get_frame_time

    @@bullets.each do |bullet|
      bullet.y -= delta * SPEED
    end
  end

  def self.draw
    LibRay.begin_drawing
    LibRay.clear_background LibRay::BLACK

    LibRay.draw_fps 0, 0

    text_size = LibRay.measure_text(TEXT, FONT_SIZE)
    LibRay.draw_text(
      TEXT,
      SCREEN_WIDTH - text_size,
      0,
      FONT_SIZE,
      LibRay::GREEN
    )

    # draw circle
    LibRay.draw_texture_v(@@circle, @@circle_pos, LibRay::WHITE)

    # draw bullets
    @@bullets.each do |bullet|
      LibRay.draw_rectangle(bullet.x, bullet.y, 3, 10, LibRay::GREEN)
    end

    LibRay.end_drawing
  end

  def self.application_loop
    while !LibRay.window_should_close?
      input_events()
      movement()
      draw()
    end
  end

  def self.run
    application_loop()
    LibRay.unload_texture(@@circle)
    LibRay.close_window
  end
end

CrayTest.run
