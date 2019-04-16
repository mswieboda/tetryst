module Tetryst
  enum Shape
    I
    J
    L
    O
    S
    T
    Z

    def matrix
      case self
      when I
        [
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
        ]
      when J
        [
          [0, 0, 1],
          [0, 0, 1],
          [0, 1, 1],
        ]
      when L
        [
          [1, 0, 0],
          [1, 0, 0],
          [1, 1, 0],
        ]
      when O
        [
          [1, 1],
          [1, 1],
        ]
      when S
        [
          [0, 1, 1],
          [0, 1, 0],
          [1, 1, 0],
        ]
      when T
        [
          [0, 0, 0],
          [0, 1, 0],
          [1, 1, 1],
        ]
      when Z
        [
          [1, 1, 0],
          [0, 1, 0],
          [0, 1, 1],
        ]
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
      end
    end
  end
end
