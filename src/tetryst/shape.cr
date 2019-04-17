module Tetryst
  enum Shape
    Empty
    I
    J
    L
    O
    S
    T
    Z

    def self.random
      # random, non-empty shape
      Shape.new(rand(Shape.values.size - 1) + 1)
    end

    def matrix
      # TODO: switch to Int8 or Bool for less used space

      case self
      when I
        [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [1, 1, 1, 1],
          [0, 0, 0, 0],
        ]
      when J
        [
          [1, 0, 0],
          [1, 1, 1],
          [0, 0, 0],
        ]
      when L
        [
          [0, 0, 1],
          [1, 1, 1],
          [0, 0, 0],
        ]
      when O
        [
          [1, 1],
          [1, 1],
        ]
      when S
        [
          [0, 1, 1],
          [1, 1, 0],
          [0, 0, 0],
        ]
      when T
        [
          [0, 1, 0],
          [1, 1, 1],
          [0, 0, 0],
        ]
      when Z
        [
          [1, 1, 0],
          [0, 1, 1],
          [0, 0, 0],
        ]
      else
        Array(Array(Int32)).new
      end
    end

    def color
      case self
      when I
        LibRay::SKYBLUE
      when J
        LibRay::BLUE
      when L
        LibRay::ORANGE
      when O
        LibRay::YELLOW
      when S
        LibRay::LIME
      when T
        LibRay::PURPLE
      when Z
        LibRay::RED
      else
        LibRay::WHITE
      end
    end
  end
end
