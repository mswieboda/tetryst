module Tetryst
  class Board
    getter cells : Array(Array(Cell))

    @tetromino : Tetromino
    @x : Int32
    @y : Int32

    # in blocks
    GRID_WIDTH  = 10
    GRID_HEIGHT = 22

    # in pixels
    BLOCK_SIZE = 32

    def initialize
      @cells = Array.new(22) { |y| Array.new(10) { |x| Cell.new } }
      @x = 0
      @y = Game::SCREEN_HEIGHT - height
      @tetromino = Tetromino.new(0, 0, Shape::T)
      # @tetromino.rotate(direction: :counter_clockwise)
    end

    def width
      GRID_WIDTH * BLOCK_SIZE
    end

    def height
      GRID_HEIGHT * BLOCK_SIZE
    end

    def place(tetromino : Tetromino)
      tetromino.matrix.each_with_index do |lines, row|
        lines.each_with_index do |block, column|
          next if block == 0
          set_cell(tetromino.grid_x + column, tetromino.grid_y + row, Cell.new(tetromino.shape))
        end
      end
    end

    def set_cell(x, y, cell : Cell)
      @cells[y][x] = cell
    end

    def update
      @tetromino.update
    end

    def print
      puts "["
      @cells.each do |line|
        puts line.join
      end
      puts "]"
    end

    def draw
      @cells.each_with_index do |cell_row, row|
        cell_row.each_with_index do |cell, column|
          cell.draw(
            x: @x + column * BLOCK_SIZE,
            y: @y + row * BLOCK_SIZE,
            size: BLOCK_SIZE
          )
        end
      end

      @tetromino.draw(
        x: @x,
        y: @y,
        size: BLOCK_SIZE
      )
    end
  end
end
