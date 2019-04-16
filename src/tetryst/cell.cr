module Tetryst
  class Cell
    getter shape : Shape
    delegate empty?, to: shape
    delegate color, to: shape

    def initialize
      @shape = Shape::Empty
    end

    def initialize(@shape : Shape)
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
        pos_x: x,
        pos_y: y,
        width: size,
        height: size,
        color: color
      )
    end
  end
end
