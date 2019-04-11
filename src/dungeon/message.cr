module Dungeon
  class Message
    getter? open

    @height : Float32
    @color : LibRay::Color

    MARGIN  = 75
    BORDER  =  5
    PADDING = 30

    TEXT_SIZE = 20
    ICON_SIZE = 16
    SPACING   =  3

    ICON_BLINK_TIMER    =   1.0
    ICON_BLINKS         = 1.125
    ICON_BLINK_INTERVAL = ICON_BLINK_TIMER / ICON_BLINKS / 2

    BORDER_COLOR     = LibRay::Color.new(r: 85, g: 85, b: 85, a: 255)
    BACKGROUND_COLOR = LibRay::Color.new(r: 51, g: 51, b: 51, a: 255)

    MAX_TEXT_WIDTH = Game::SCREEN_WIDTH - MARGIN * 2 - BORDER * 2 - PADDING * 2

    def initialize(@text : String)
      @sprite_font = LibRay.get_default_font
      @font_size = TEXT_SIZE
      @spacing = SPACING
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

      @icon_blink_timer = Timer.new(ICON_BLINK_TIMER)
      @open = false
      @active = false
    end

    def open
      @open = true
      @active = true
    end

    def done?
      true
    end

    def dismiss
      return unless done?

      close
    end

    def close
      @open = false
    end

    def closed?
      !@open
    end

    def just_closed?
      @active && closed?
    end

    def update
      delta_t = LibRay.get_frame_time

      if @icon_blink_timer.done?
        @icon_blink_timer.restart
      else
        @icon_blink_timer.increase(delta_t)
      end

      @active = false if just_closed?

      dismiss if LibRay.key_pressed?(LibRay::KEY_ENTER) || LibRay.key_pressed?(LibRay::KEY_SPACE)
    end

    def draw
      return unless open?

      # border
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

      # background
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

      # text
      LibRay.draw_text_ex(
        sprite_font: @sprite_font,
        text: @text,
        position: @position,
        font_size: @font_size,
        spacing: @spacing,
        color: @color
      )

      draw_done_icon
    end

    def draw_done_icon
      if (@icon_blink_timer.time / ICON_BLINK_INTERVAL).to_i % 2 == 1
        LibRay.draw_triangle(
          v1: LibRay::Vector2.new(
            x: Game::SCREEN_WIDTH - MARGIN - BORDER - PADDING / 2 - ICON_SIZE,
            y: Game::SCREEN_HEIGHT - MARGIN - BORDER - PADDING / 2 - ICON_SIZE
          ),
          v2: LibRay::Vector2.new(
            x: Game::SCREEN_WIDTH - MARGIN - BORDER - PADDING / 2 - ICON_SIZE / 2,
            y: Game::SCREEN_HEIGHT - MARGIN - BORDER - PADDING / 2
          ),
          v3: LibRay::Vector2.new(
            x: Game::SCREEN_WIDTH - MARGIN - BORDER - PADDING / 2,
            y: Game::SCREEN_HEIGHT - MARGIN - BORDER - PADDING / 2 - ICON_SIZE
          ),
          color: @color
        )
      end
    end
  end
end
