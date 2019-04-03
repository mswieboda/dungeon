require "./location"

module Dungeon
  class Level
    getter level_width : Int32
    getter level_height : Int32
    getter player : Player
    getter? game_over

    @game_over_text_color : LibRay::Color

    GAME_OVER_TIME = 150

    def initialize(@level_width, @level_height)
      @drawables = [] of Entity
      @entities = [] of Entity

      # player
      @player = Player.new(
        loc: Location.new(150, 150),
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        )
      )

      @entities << @player

      # walls
      @entities << Wall.new(loc: Location.new(level_width / 2, 16), width: level_width, height: 32)
      @entities << Wall.new(loc: Location.new(level_width - 16, level_height / 2), width: 32, height: level_height)
      @entities << Wall.new(loc: Location.new(level_width / 2, level_height - 16), width: level_width, height: 32)
      @entities << Wall.new(loc: Location.new(16, level_height / 2), width: 32, height: level_height)
      @entities << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # items
      @entities << Item.new(loc: Location.new(300, 150), name: :key)
      @entities << Item.new(loc: Location.new(200, 150), name: :hearts, animation_frames: 2, animation_rows: 3, animation_row: 0, animation_fps: 5)

      # enemies
      @entities << Enemy.new(
        loc: Location.new(300, 300),
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        )
      )

      # game over
      @game_over_timer = 0
      @game_over = false
      @game_over_text_font = LibRay.get_default_font
      @game_over_text = "GAME OVER"
      @game_over_text_font_size = 100
      @game_over_text_spacing = 15
      @game_over_text_color = LibRay::WHITE
      @game_over_text_measured = LibRay.measure_text_ex(
        sprite_font: @game_over_text_font,
        text: @game_over_text,
        font_size: @game_over_text_font_size,
        spacing: @game_over_text_spacing
      )
      @game_over_text_position = LibRay::Vector2.new(
        x: level_width / 2 - @game_over_text_measured.x / 2,
        y: level_height / 2 - @game_over_text_measured.y,
      )
    end

    def draw
      @drawables.each(&.draw)

      if game_over?
        LibRay.draw_text_ex(
          sprite_font: @game_over_text_font,
          text: @game_over_text,
          position: @game_over_text_position,
          font_size: @game_over_text_font_size,
          spacing: @game_over_text_spacing,
          color: @game_over_text_color
        )
      end
    end

    def update
      @drawables.clear

      @entities.each { |entity| entity.update(@entities.reject(entity)) unless entity.removed? }
      @entities.reject!(&.removed?)

      if @player.dead?
        if @game_over_timer >= GAME_OVER_TIME
          @game_over_timer = 0
          @game_over = true
        else
          @game_over_timer += 1
        end
      end

      # change order of drawing based on y coordinates
      @drawables.concat(@entities)
      @drawables.sort_by!(&.y)
    end
  end
end
