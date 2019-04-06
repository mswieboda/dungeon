module Dungeon
  class HeadsUpDisplay
    @hearts_sprite : Sprite
    @bombs_text_color : LibRay::Color

    def initialize
      @hearts_sprite = Sprite.get("items/hearts")

      @default_font = LibRay.get_default_font

      @full_hearts = 0
      @half_hearts = 0
      @empty_hearts = 0

      @bombs_text = "B: 0"
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
    end

    def update(player)
      @full_hearts = full_hearts(player)
      @half_hearts = half_hearts(player)
      @empty_hearts = empty_hearts(player)

      @bombs_text = "B: #{player.bombs_left}"
    end

    def draw
      draw_hearts
      draw_bombs
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

      @bombs_text_position = LibRay::Vector2.new(
        x: hearts_x,
        y: hearts_y - @bombs_text_measured.y / 2,
      )
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
