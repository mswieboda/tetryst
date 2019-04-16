module Tetryst
  class Board
    getter grid : Array(Array(Cell))

    # in blocks
    GRID_WIDTH  = 10
    GRID_HEIGHT = 22

    # in pixels
    BLOCK_SIZE = 64

    def initialize
      @grid = Array.new(22) { |y| Array.new(10) { |x| Cell.new } }
    end

    def set_cell(x, y, cell : Cell)
      @grid[y][x] = cell
    end

    def print
      puts "["
      @grid.each do |line|
        puts line.join
      end
      puts "]"
    end

    def draw
    end
  end
end
