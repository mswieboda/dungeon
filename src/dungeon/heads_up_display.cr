module Dungeon
  class HeadsUpDisplay
    @player : Player
    @width : Int32
    @height : Int32
    @hearts_sprite : LibRay::Texture2D

    def initialize(@player, @width, @height, @hearts_sprite)
    end

    def update
    end

    def draw
      draw_hearts
    end

    def draw_hearts
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
  end
end
