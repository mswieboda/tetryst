module Tetryst
  enum Status
    Free
    Blocked
    Collided
  end

  class Tetromino
    property grid_x : Int32
    property grid_y : Int32
    getter ghost_y : Int32
    getter cells : Array(Array(Cell))
    getter shape : Shape
    getter status : Status

    GHOST_INSET_SIZE  = 1
    GHOST_INSET_COLOR = LibRay::WHITE

    def initialize(@shape : Shape, @grid_x = 0, @grid_y = 0)
      @cells = @shape.matrix.map do |rows|
        rows.map do |value|
          Cell.new(
            shape: value == 0 ? Shape::Empty : shape
          )
        end
      end
      @status = Status::Free
      @ghost_y = @grid_y
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
        cell_y = grid_y + row_index + delta_y

        row.each_with_index do |cell, column_index|
          next if cell.empty?

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

    def hard_drop
      @grid_y = @ghost_y
    end

    def update_ghost(grid_cells)
      grid_cells.each_with_index do |grid_row, grid_row_index|
        grid_row.each_with_index do |grid_column, grid_column_index|
          next if grid_column_index < grid_x || grid_column_index > grid_x + cells.size

          cells.each_with_index do |row, row_index|
            cell_y = grid_row_index + row_index

            row.each_with_index do |cell, column_index|
              next if cell.empty?

              cell_x = grid_x + column_index

              next if cell_x < 0 || cell_x >= Board::GRID_WIDTH

              if cell_y >= Board::GRID_HEIGHT
                @ghost_y = cell_y - row_index - 1
                return
              end

              grid_cell = grid_cells[cell_y][cell_x]
              next if grid_cell.empty?

              @ghost_y = cell_y - row_index - 1
              return
            end
          end
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

      # ghost
      cells.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          next if cell.empty?

          LibRay.draw_rectangle_lines(
            pos_x: x + (grid_x + column_index) * size + GHOST_INSET_SIZE,
            pos_y: y + @ghost_y * size + (row_index * size) + GHOST_INSET_SIZE,
            width: size - GHOST_INSET_SIZE * 2,
            height: size - GHOST_INSET_SIZE * 2,
            color: GHOST_INSET_COLOR
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
