require "cray"

# This example will automatically scale with the window.

LibRay.set_config_flags LibRay::FLAG_WINDOW_RESIZABLE
LibRay.init_window 640, 480, "Example: hello_world"

TEXT = "Hello, world!"
# font = LibRay.load_sprite_font(File.join(__DIR__, ""))

while !LibRay.window_should_close?
  LibRay.begin_drawing
  LibRay.clear_background LibRay::WHITE

  w = LibRay.get_screen_width
  h = LibRay.get_screen_height

  font_size = Math.min(w, h) * 0.2
  # spacing = font_size/10

  text_size = LibRay.measure_text(TEXT, font_size)

  x = w/2.0 - text_size/2.0
  y = h/2.0 # - text_size/2.0

  LibRay.draw_text(TEXT, x, y, font_size, LibRay::BLACK)

  LibRay.end_drawing
end

LibRay.close_window
