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

      # load sprites
      player_sprite = LibRay.load_texture(File.join(__DIR__, "assets/player.png"))
      sword_sprite = LibRay.load_texture(File.join(__DIR__, "assets/sword-attack.png"))
      keys_sprite = LibRay.load_texture(File.join(__DIR__, "assets/items/keys.png"))
      @hearts_sprite = LibRay.load_texture(File.join(__DIR__, "assets/items/hearts.png"))

      # player
      @player = Player.new(
        loc: Location.new(150, 150),
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        ),
        sprite: player_sprite,
        weapon_sprite: sword_sprite
      )

      @entities << @player

      # walls
      @entities << Wall.new(loc: Location.new(level_width / 2, 16), width: level_width, height: 32)
      @entities << Wall.new(loc: Location.new(level_width - 16, level_height / 2), width: 32, height: level_height)
      @entities << Wall.new(loc: Location.new(level_width / 2, level_height - 16), width: level_width, height: 32)
      @entities << Wall.new(loc: Location.new(16, level_height / 2), width: 32, height: level_height)
      @entities << Wall.new(loc: Location.new(500, 500), width: 32, height: 100)

      # items
      @entities << Item.new(loc: Location.new(300, 150), sprite: keys_sprite, animation_rows: 4)
      @entities << Item.new(loc: Location.new(200, 150), sprite: @hearts_sprite, animation_frames: 2, animation_rows: 3, animation_row: 0, animation_fps: 5)

      # enemies
      @entities << Enemy.new(
        loc: Location.new(300, 300),
        collision_box: Box.new(
          loc: Location.new(-12, 16),
          width: 24,
          height: 16
        ),
        sprite: player_sprite
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

      draw_player_heads_up_display

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

    def draw_player_heads_up_display
      hearts_width = @hearts_sprite.width / 2
      hearts_height = @hearts_sprite.height / 3
      hearts_x = 16
      hearts_y = 16
      hearts_x_padding = -8

      sprite_row = 0

      @player.full_hearts.times do |heart_num|
        draw_heart(hearts_x, hearts_y, sprite_row, hearts_width, hearts_height)

        hearts_x += hearts_width + hearts_x_padding
      end

      sprite_row = 1

      @player.half_hearts.times do |heart_num|
        draw_heart(hearts_x, hearts_y, sprite_row, hearts_width, hearts_height)

        hearts_x += hearts_width + hearts_x_padding
      end
    end

    def draw_heart(x, y, sprite_row, width, height)
      LibRay.draw_texture_pro(
        texture: @hearts_sprite,
        source_rec: LibRay::Rectangle.new(
          x: 0,
          y: sprite_row * height,
          width: width,
          height: height
        ),
        dest_rec: LibRay::Rectangle.new(
          x: x,
          y: y,
          width: width,
          height: height
        ),
        origin: LibRay::Vector2.new(
          x: width / 2,
          y: height / 2
        ),
        rotation: 0,
        tint: LibRay::WHITE
      )
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
