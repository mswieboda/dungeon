module Dungeon
  class TypedMessage < Message
    @text_index : Int32

    SLOWEST =   0.2
    SLOW    =   0.1
    MEDIUM  =  0.05
    FAST    = 0.025
    FASTEST = 0.001

    def initialize(text : Array(String), @type_speed = MEDIUM)
      super(text)

      @timer = Timer.new(@type_speed)
      @text_index = 0
      @done = false
    end

    def initialize(text : String, type_speed = MEDIUM)
      initialize([text], type_speed)
    end

    def text_to_type
      if @text_index > 0
        text[0..@text_index - 1]
      else
        ""
      end
    end

    def dismiss
      return unless done?

      if @text_line_index >= @text.size - 1
        close
      else
        next_line
      end
    end

    def next_line
      super

      @done = false
      @text_index = 0
      @timer.restart
    end

    def done?
      @done
    end

    def update
      super

      if !@done && @timer.done?
        @timer.restart

        if @text_index >= text.size
          @done = true
        else
          @text_index += @type_speed == FASTEST ? 6 : 3
        end
      else
        @timer.increase(LibRay.get_frame_time)
      end
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
        text: text_to_type,
        position: @position,
        font_size: @font_size,
        spacing: @spacing,
        color: @color
      )

      draw_done_icon
    end

    def draw_done_icon
      if @done && (@icon_blink_timer.time / ICON_BLINK_INTERVAL).to_i % 2 == 1
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
