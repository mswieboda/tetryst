module Tetryst
  class Tetronimo
    @matrix : Array(Array(Int32))

    def initialize(@grid_x : Int32, @grid_y : Int32, @shape : Shape)
      @matrix = @shape.matrix
    end

    def rotate(direction = :clockwise)
      @matrix = @matrix.map_with_index do |_line, index|
        if direction == :clockwise
          @matrix.map { |line| line[index] }.reverse
        else
          @matrix.map { |line| line[index] }
        end
      end
    end

    def draw
    end

    def print
      puts "["
      @matrix.each do |line|
        puts line.join
      end
      puts "]"
    end
  end
end
