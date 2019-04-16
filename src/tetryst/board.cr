module Tetryst
  class Board
    getter cells : Array(Array(Cell))
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
    end

    def width
      GRID_WIDTH * BLOCK_SIZE
    end

    def height
      GRID_HEIGHT * BLOCK_SIZE
    end

    def set_cell(x, y, cell : Cell)
      @cells[y][x] = cell
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
    end
  end
end
