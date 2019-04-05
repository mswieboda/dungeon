module Dungeon
  class Game
    getter? game_over

    @level : Level
    @game_over_text_color : LibRay::Color

    SCREEN_WIDTH  = 1024
    SCREEN_HEIGHT =  768

    TARGET_FPS = 60
    DRAW_FPS   = false

    GAME_OVER_TIME = 150

    def initialize
      LibRay.init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Dungeon")
      LibRay.set_target_fps(TARGET_FPS)

      player_sprite = LibRay.load_texture(File.join(__DIR__, "assets/player.png"))
      sword_sprite = LibRay.load_texture(File.join(__DIR__, "assets/sword-attack.png"))

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

      @hud = HeadsUpDisplay.new(@player, SCREEN_WIDTH, SCREEN_HEIGHT, @hearts_sprite)

      @level = Level.new(
        player: @player,
        width: SCREEN_WIDTH,
        height: SCREEN_HEIGHT,

        # TODO: find a way to reuse sprites between levels/HUD, etc
        enemy_sprite: player_sprite,
        hearts_sprite: @hearts_sprite,
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
        x: SCREEN_WIDTH / 2 - @game_over_text_measured.x / 2,
        y: SCREEN_HEIGHT / 2 - @game_over_text_measured.y,
      )
    end

    def run
      while !LibRay.window_should_close?
        update
        draw_init
      end

      close
    end

    def update
      @level.update

      if @player.dead?
        if @game_over_timer >= GAME_OVER_TIME
          @game_over_timer = 0
          @game_over = true
        else
          @game_over_timer += 1
        end
      end
    end

    def draw
      @level.draw

      @hud.draw

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

      LibRay.draw_fps(0, 0) if DRAW_FPS
    end

    def draw_init
      LibRay.begin_drawing
      LibRay.clear_background LibRay::BLACK

      draw

      LibRay.end_drawing
    end

    def close
      LibRay.close_window
    end
  end
end