module Tetryst
  enum Status
    Free
    Blocked
    Collided
  end

  class Tetromino
    property grid_x : Int32
    property grid_y : Int32
    getter cells : Array(Array(Cell))
    getter shape : Shape
    getter status : Status

    def initialize(@shape : Shape, @grid_x = 0, @grid_y = 0)
      @cells = @shape.matrix.map do |rows|
        rows.map do |value|
          Cell.new(
            shape: value == 0 ? Shape::Empty : shape
          )
        end
      end
      @status = Status::Free
    end

    def free
      @status = Status::Free
    end

    def blocked
      @status = Status::Blocked
    end

    def collided
      @status = Status::Collided
    end

    def rotate(direction)
      @cells = cells.map_with_index do |_rows, row|
        if direction == :clockwise
          cells.reverse.map { |b| b[row] }
        else
          cells.map { |b| b.reverse[row] }
        end
      end
    end

    def draw(x, y, size)
      cells.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          next if cell.empty?

          cell.draw(
            x: x + (grid_x + column_index) * size,
            y: y + (grid_y + row_index) * size,
            size: size
          )
        end
      end
    end

    def print
      puts "["
      cells.each do |row|
        puts row.join
      end
      puts "]"
    end
  end
end
