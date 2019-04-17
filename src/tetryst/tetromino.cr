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

    def update_status(grid_cells, delta_x = 0, delta_y = 0)
      cells.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          next if cell.empty?

          cell_y = grid_y + row_index + delta_y
          cell_x = grid_x + column_index + delta_x

          if cell_y < 0
            collided
            return
          end

          if cell_y >= Board::GRID_HEIGHT
            blocked
            return
          end

          if cell_x < 0 || cell_x >= Board::GRID_WIDTH
            collided
            return
          end

          grid_cell = grid_cells[cell_y][cell_x]
          next if grid_cell.empty?

          if delta_x == 0
            blocked
            return
          else
            collided
            return
          end
        end
      end

      free
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
