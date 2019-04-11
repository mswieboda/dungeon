module Dungeon
  class Message
    @height : Float32
    @color : LibRay::Color

    MARGIN  = 75
    BORDER  =  5
    PADDING = 30

    BORDER_COLOR     = LibRay::Color.new(r: 85, g: 85, b: 85, a: 255)
    BACKGROUND_COLOR = LibRay::Color.new(r: 51, g: 51, b: 51, a: 255)

    MAX_TEXT_WIDTH = Game::SCREEN_WIDTH - MARGIN * 2 - BORDER * 2 - PADDING * 2

    def initialize(@text : String)
      @sprite_font = LibRay.get_default_font
      @font_size = 20
      @spacing = 3
      @color = LibRay::WHITE
      @measured = LibRay.measure_text_ex(
        sprite_font: @sprite_font,
        text: @text,
        font_size: @font_size,
        spacing: @spacing
      )

      @height = @measured.y

      puts "#{self.class.name} line in message is too long, message:\n<\n#{@text}\n>" if @measured.x > MAX_TEXT_WIDTH

      @position = LibRay::Vector2.new(
        x: MARGIN + BORDER + PADDING,
        y: Game::SCREEN_HEIGHT - MARGIN - BORDER - PADDING - @height
      )
    end

    def draw
      LibRay.draw_rectangle_v(
        position: LibRay::Vector2.new(
          x: MARGIN,
          y: Game::SCREEN_HEIGHT - MARGIN - BORDER * 2 - PADDING * 2 - @height
        ),
        size: LibRay::Vector2.new(
          x: Game::SCREEN_WIDTH - MARGIN * 2,
          y: BORDER * 2 + PADDING * 2 + @height
        ),
        color: BORDER_COLOR
      )

      LibRay.draw_rectangle_v(
        position: LibRay::Vector2.new(
          x: MARGIN + BORDER,
          y: Game::SCREEN_HEIGHT - MARGIN - BORDER - PADDING * 2 - @height
        ),
        size: LibRay::Vector2.new(
          x: Game::SCREEN_WIDTH - MARGIN * 2 - BORDER * 2,
          y: PADDING * 2 + @height
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
