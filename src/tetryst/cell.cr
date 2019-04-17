module Tetryst
  class Cell
    property grid_x : Int32
    property grid_y : Int32
    getter shape : Shape
    delegate empty?, to: shape
    delegate color, to: shape

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

      LibRay.draw_rectangle(
        pos_x: x + grid_x * size,
        pos_y: y + grid_y * size,
        width: size,
        height: size,
        color: color
      )
    end
  end
end
