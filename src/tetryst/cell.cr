module Tetryst
  class Cell
    property grid_x : Int32
    property grid_y : Int32
    getter shape : Shape
    delegate empty?, to: shape
    delegate color, to: shape

    INSET_SIZE  = 2
    INSET_COLOR = LibRay::WHITE

    def initialize(@grid_x : Int32, @grid_y : Int32, @shape = Shape::Empty)
    end

    def initialize(@shape : Shape)
      initialize(0, 0, shape)
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
        pos_x: x + grid_x * size,
        pos_y: y + grid_y * size,
        width: size,
        height: size,
        color: color
      )

      # inset
      LibRay.draw_rectangle_lines(
        pos_x: x + grid_x * size + INSET_SIZE,
        pos_y: y + grid_y * size + INSET_SIZE,
        width: size - INSET_SIZE * 2,
        height: size - INSET_SIZE * 2,
        color: INSET_COLOR
      )
    end
  end
end
