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

    # in seconds
    DROP_TIME = 0.25

    BORDER_WIDTH = 10

    def initialize(@drop_time = DROP_TIME)
      @cells = Array.new(22) { |y| Array.new(10) { |x| Cell.new(grid_x: x, grid_y: y) } }
      @x = BORDER_WIDTH
      @y = Game::SCREEN_HEIGHT - height - BORDER_WIDTH
      @tetromino = Tetromino.new(0, 0, Shape::T)
      # @tetromino.rotate(direction: :counter_clockwise)
      @drop_timer = Timer.new(@drop_time)
    end

    def width
      GRID_WIDTH * BLOCK_SIZE
    end

    def height
      GRID_HEIGHT * BLOCK_SIZE
    end

    def place(tetromino : Tetromino)
      tetromino.blocks.each do |rows|
        rows.each do |block|
          next if block.empty?
          set_cell(
            Cell.new(
              grid_x: tetromino.grid_x + block.grid_x,
              grid_y: tetromino.grid_y + block.grid_y,
              shape: tetromino.shape
            )
          )
        end
      end
    end

    def new_tetromino
      @tetromino = Tetromino.new(0, 0, Shape::Z)
    end

    def set_cell(cell : Cell)
      @cells[cell.grid_y][cell.grid_x] = cell
    end

    def update
      update_tetromino
    end

    def update_tetromino
      delta_x = delta_y = 0

      if LibRay.key_pressed?(LibRay::KEY_LEFT) || LibRay.key_pressed?(LibRay::KEY_A)
        delta_x -= 1
      end

      if LibRay.key_pressed?(LibRay::KEY_RIGHT) || LibRay.key_pressed?(LibRay::KEY_D)
        delta_x += 1
      end

      if LibRay.key_pressed?(LibRay::KEY_DOWN) || LibRay.key_pressed?(LibRay::KEY_S)
        delta_y += 1
      end

      if @drop_timer.done?
        delta_y += 1
        @drop_timer.reset
      else
        @drop_timer.increase(LibRay.get_frame_time)
      end

      # check for collisions
      status = tetromino_status(delta_x, delta_y)

      case status
      when :can_move
        @tetromino.grid_x += delta_x
        @tetromino.grid_y += delta_y
      when :blocked
        # place tetromino
        place(@tetromino)
        # make a new one at the top
        new_tetromino
      when :out_of_bounds
        # don't do anything
        # maybe an alert color flash, vibration, or sound?
      end
    end

    def tetromino_status(delta_x, delta_y)
      @tetromino.blocks.each do |rows|
        rows.each do |block|
          if block.empty?
            next
          else
            cell_y = @tetromino.grid_y + block.grid_y + delta_y
            cell_x = @tetromino.grid_x + block.grid_x + delta_x

            if cell_y < 0
              return :out_of_bounds
            elsif cell_y >= GRID_HEIGHT
              return :blocked
            else
              if cell_x < 0 || cell_x >= GRID_WIDTH
                return :out_of_bounds
              else
                cell = @cells[cell_y][cell_x]
                if cell.empty?
                  next
                else
                  if delta_x == 0
                    return :blocked
                  else
                    return :out_of_bounds
                  end
                end
              end
            end
          end
        end
      end

      :can_move
    end

    def print
      puts "["
      @cells.each do |line|
        puts line.join
      end
      puts "]"
    end

    def draw
      @cells.each do |cell_row|
        cell_row.each do |cell|
          cell.draw(
            x: @x,
            y: @y,
            size: BLOCK_SIZE
          )
        end
      end

      @tetromino.draw(
        x: @x,
        y: @y,
        size: BLOCK_SIZE
      )

      # border
      BORDER_WIDTH.times do |border|
        LibRay.draw_rectangle_lines(
          pos_x: @x - border,
          pos_y: @y - border,
          width: width + border * 2,
          height: height + border * 2,
          color: LibRay::WHITE
        )
      end
    end
  end
end
