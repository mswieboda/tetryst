module Tetryst
  class Label
    property text : String
    property x : Int32
    property y : Int32
    getter width : Int32
    getter height : Int32

    @color : LibRay::Color

    FONT_SIZE = 20
    SPACING   =  3
    PADDING   = 15

    DEFAULT_COLOR = LibRay::WHITE

    def initialize(@x = 0, @y = 0, @text = "")
      measure = LibRay.measure_text_ex(
        sprite_font: LibRay.get_default_font,
        text: @text,
        font_size: FONT_SIZE,
        spacing: SPACING
      )
      @width = measure.x.round.to_i
      @height = measure.y.round.to_i

      @color = DEFAULT_COLOR
    end

    def resize_to_text
      measure = LibRay.measure_text_ex(
        sprite_font: LibRay.get_default_font,
        text: @text,
        font_size: FONT_SIZE,
        spacing: SPACING
      )
      @width = measure.x.round.to_i
      @height = measure.y.round.to_i
    end

    def draw
      LibRay.draw_text_ex(
        sprite_font: LibRay.get_default_font,
        text: @text,
        position: LibRay::Vector2.new(
          x: @x,
          y: @y + @height / 2
        ),
        font_size: FONT_SIZE,
        spacing: SPACING,
        color: @color
      )
    end
  end
end
