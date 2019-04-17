module Tetryst
  class Tetromino
    property grid_x : Int32
    property grid_y : Int32
    getter blocks : Array(Array(Cell))
    getter shape : Shape

    def initialize(@grid_x : Int32, @grid_y : Int32, @shape : Shape)
      @blocks = @shape.matrix.map_with_index do |rows, row|
        rows.map_with_index do |value, column|
          Cell.new(
            grid_x: column,
            grid_y: row,
            shape: value == 0 ? Shape::Empty : shape
          )
        end
      end
    end

    def rotate(direction = :clockwise)
      @blocks = blocks.map_with_index do |_rows, row|
        if direction == :clockwise
          blocks.map { |b| b[row] }.reverse
        else
          blocks.map { |b| b[row] }
        end
      end

      @blocks.each_with_index do |rows, row|
        rows.each_with_index do |cell, column|
          cell.grid_x = column
          cell.grid_y = row
        end
      end
    end

    def draw(x, y, size)
      blocks.each do |rows|
        rows.each do |cell|
          next if cell.empty?

          cell.draw(
            x: x + grid_x * size,
            y: y + grid_y * size,
            size: size
          )
        end
      end
    end

    def print
      puts "["
      blocks.each do |rows|
        puts rows.join
      end
      puts "]"
    end
  end
end
