module Dungeon
  class HeadsUpDisplay
    @hearts_sprite : Sprite
    @bombs_text_color : LibRay::Color
    @keys_text_color : LibRay::Color
    @arrows_text_color : LibRay::Color

    def initialize
      @hearts_sprite = Sprite.get("items/hearts")

      @default_font = LibRay.get_default_font

      @full_hearts = 0
      @half_hearts = 0
      @empty_hearts = 0

      @keys_text = "K:0"
      @keys_text_position = LibRay::Vector2.new
      @keys_text_font_size = 10
      @keys_text_spacing = 3
      @keys_text_color = LibRay::WHITE
      @keys_text_measured = LibRay.measure_text_ex(
        sprite_font: @default_font,
        text: @keys_text,
        font_size: @keys_text_font_size,
        spacing: @keys_text_spacing
      )
      @keys_text_position = LibRay::Vector2.new(
        x: 8,
        y: 16 + @hearts_sprite.height / 2,
      )

      @bombs_text = "B:0"
      @bombs_text_position = LibRay::Vector2.new
      @bombs_text_font_size = 10
      @bombs_text_spacing = 3
      @bombs_text_color = LibRay::WHITE
      @bombs_text_measured = LibRay.measure_text_ex(
        sprite_font: @default_font,
        text: @bombs_text,
        font_size: @bombs_text_font_size,
        spacing: @bombs_text_spacing
      )
      @bombs_text_position = LibRay::Vector2.new(
        x: @keys_text_position.x,
        y: @keys_text_position.y + @keys_text_measured.y + 5,
      )

      @arrows_text = "A:0"
      @arrows_text_position = LibRay::Vector2.new
      @arrows_text_font_size = 10
      @arrows_text_spacing = 3
      @arrows_text_color = LibRay::WHITE
      @arrows_text_measured = LibRay.measure_text_ex(
        sprite_font: @default_font,
        text: @arrows_text,
        font_size: @arrows_text_font_size,
        spacing: @arrows_text_spacing
      )
      @arrows_text_position = LibRay::Vector2.new(
        x: @bombs_text_position.x,
        y: @bombs_text_position.y + @bombs_text_measured.y + 5,
      )
    end

    def update(player)
      @full_hearts = full_hearts(player)
      @half_hearts = half_hearts(player)
      @empty_hearts = empty_hearts(player)

      @keys_text = "K:#{player.keys_left}"
      @bombs_text = "B:#{player.bombs_left}"
      @arrows_text = "A:#{player.arrows_left}"
    end

    def draw
      draw_hearts
      draw_keys
      draw_bombs
      draw_arrows
    end

    def draw_hearts
      hearts_width = @hearts_sprite.width
      hearts_height = @hearts_sprite.height
      hearts_x = 16
      hearts_y = 16
      hearts_x_padding = -8

      sprite_row = 0

      @full_hearts.times do |heart_num|
        draw_heart(hearts_x, hearts_y, sprite_row, hearts_width, hearts_height)

        hearts_x += hearts_width + hearts_x_padding
      end

      sprite_row = 1

      @half_hearts.times do |heart_num|
        draw_heart(hearts_x, hearts_y, sprite_row, hearts_width, hearts_height)

        hearts_x += hearts_width + hearts_x_padding
      end

      sprite_row = 2

      @empty_hearts.times do |heart_num|
        draw_heart(hearts_x, hearts_y, sprite_row, hearts_width, hearts_height)

        hearts_x += hearts_width + hearts_x_padding
      end
    end

    def draw_bombs
      LibRay.draw_text_ex(
        sprite_font: @default_font,
        text: @bombs_text,
        position: @bombs_text_position,
        font_size: @bombs_text_font_size,
        spacing: @bombs_text_spacing,
        color: @bombs_text_color
      )
    end

    def draw_keys
      LibRay.draw_text_ex(
        sprite_font: @default_font,
        text: @keys_text,
        position: @keys_text_position,
        font_size: @keys_text_font_size,
        spacing: @keys_text_spacing,
        color: @keys_text_color
      )
    end

    def draw_arrows
      LibRay.draw_text_ex(
        sprite_font: @default_font,
        text: @arrows_text,
        position: @arrows_text_position,
        font_size: @arrows_text_font_size,
        spacing: @arrows_text_spacing,
        color: @arrows_text_color
      )
    end

    def draw_heart(x, y, sprite_row, width, height)
      LibRay.draw_texture_pro(
        texture: @hearts_sprite.texture,
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

    def full_hearts(player : Player, hit_points = player.hit_points)
      (hit_points / FullHeart::HIT_POINTS).to_i
    end

    def half_hearts(player)
      leftover_hit_points = player.hit_points - (full_hearts(player) * FullHeart::HIT_POINTS).to_i
      (leftover_hit_points / HalfHeart::HIT_POINTS).to_i
    end

    def empty_hearts(player)
      full_hearts(player, player.max_hit_points - player.hit_points)
    end
  end
end
