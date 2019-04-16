module Tetryst
  class Tetromino
    getter grid_x : Int32
    getter grid_y : Int32
    getter matrix : Array(Array(Int32))
    getter shape : Shape

    DROP_TIME = 0.5

    def initialize(@grid_x : Int32, @grid_y : Int32, @shape : Shape, @drop_time = DROP_TIME)
      @matrix = @shape.matrix
      @drop_timer = Timer.new(@drop_time)
    end

    def rotate(direction = :clockwise)
      @matrix = matrix.map_with_index do |_line, index|
        if direction == :clockwise
          matrix.map { |line| line[index] }.reverse
        else
          matrix.map { |line| line[index] }
        end
      end
    end

    def update
      if LibRay.key_pressed?(LibRay::KEY_LEFT) || LibRay.key_pressed?(LibRay::KEY_A)
        @grid_x -= 1
      end

      if LibRay.key_pressed?(LibRay::KEY_RIGHT) || LibRay.key_pressed?(LibRay::KEY_D)
        @grid_x += 1
      end

      if LibRay.key_pressed?(LibRay::KEY_DOWN) || LibRay.key_pressed?(LibRay::KEY_S)
        @grid_y += 1
      end

      if @drop_timer.done?
        @grid_y += 1
        @drop_timer.reset
      else
        @drop_timer.increase(LibRay.get_frame_time)
      end
    end

    def draw(x, y, size)
      matrix.each_with_index do |lines, row|
        lines.each_with_index do |block, column|
          next if block == 0

          Cell.new(shape).draw(
            x: x + (grid_x + column) * size,
            y: y + (grid_y + row) * size,
            size: size
          )
        end
      end
    end

    def print
      puts "["
      matrix.each do |line|
        puts line.join
      end
      puts "]"
    end
  end
end
