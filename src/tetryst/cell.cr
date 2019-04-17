module Tetryst
  class Cell
    property shape : Shape
    delegate empty?, to: shape
    delegate color, to: shape

    INSET_SIZE  = 2
    INSET_COLOR = LibRay::WHITE

    def initialize(@shape = Shape::Empty)
    end

    def empty?
      shape.empty?
    end

    def to_s(io : IO)
      io << shape.value
    end

    def draw(x, y, size)
      return if empty?

      # cell background
      LibRay.draw_rectangle(
        pos_x: x,
        pos_y: y,
        width: size,
        height: size,
        color: color
      )

      # inset
      LibRay.draw_rectangle_lines(
        pos_x: x + INSET_SIZE,
        pos_y: y + INSET_SIZE,
        width: size - INSET_SIZE * 2,
        height: size - INSET_SIZE * 2,
        color: INSET_COLOR
      )
    end
  end
end
