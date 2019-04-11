module Dungeon
  class Message
    @color : LibRay::Color

    MARGIN  = 100
    BORDER  =   5
    PADDING =  50
    HEIGHT  = 300

    BORDER_COLOR     = LibRay::Color.new(r: 85, g: 85, b: 85, a: 255)
    BACKGROUND_COLOR = LibRay::Color.new(r: 51, g: 51, b: 51, a: 255)

    def initialize(@text : String)
      @sprite_font = LibRay.get_default_font
      @font_size = 30
      @spacing = 5
      @color = LibRay::WHITE
      @measured = LibRay.measure_text_ex(
        sprite_font: @sprite_font,
        text: @text,
        font_size: @font_size,
        spacing: @spacing
      )
      @position = LibRay::Vector2.new(
        x: MARGIN + BORDER + PADDING,
        y: Game::SCREEN_HEIGHT - MARGIN - BORDER - (HEIGHT - PADDING - BORDER),
      )
    end

    def draw
      LibRay.draw_rectangle_v(
        position: LibRay::Vector2.new(
          x: MARGIN,
          y: Game::SCREEN_HEIGHT - MARGIN - HEIGHT
        ),
        size: LibRay::Vector2.new(
          x: Game::SCREEN_WIDTH - MARGIN * 2,
          y: HEIGHT
        ),
        color: BORDER_COLOR
      )

      LibRay.draw_rectangle_v(
        position: LibRay::Vector2.new(
          x: MARGIN + BORDER,
          y: Game::SCREEN_HEIGHT - MARGIN - HEIGHT + BORDER
        ),
        size: LibRay::Vector2.new(
          x: Game::SCREEN_WIDTH - MARGIN * 2 - BORDER * 2,
          y: HEIGHT - BORDER * 2
        ),
        color: BACKGROUND_COLOR
      )

      LibRay.draw_text_ex(
        sprite_font: @sprite_font,
        text: @text,
        position: @position,
        font_size: @font_size,
        spacing: @spacing,
        color: @color
      )
    end
  end
end
