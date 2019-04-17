module Tetryst
  class Board
    getter? game_over
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
    DROP_TIME               = 0.25
    BLOCKED_TIME            =  0.2
    KEY_DOWN_INITIAL_TIME   =  0.2
    KEY_DOWN_TIME           = 0.06
    KEY_DOWN_SOFT_DROP_RATE =    2

    BORDER_WIDTH = 10

    def initialize(@drop_time = DROP_TIME)
      @cells = Array.new(GRID_HEIGHT) { Array.new(GRID_WIDTH) { Cell.new } }
      @x = BORDER_WIDTH
      @y = Game::SCREEN_HEIGHT - height - BORDER_WIDTH
      @tetromino = new_tetromino
      @drop_timer = Timer.new(@drop_time)
      @blocked_timer = Timer.new(BLOCKED_TIME)
      @key_down_initial_timer = Timer.new(KEY_DOWN_INITIAL_TIME)
      @key_down_timer = Timer.new(KEY_DOWN_TIME)
      @tetromino_did_move = false
      @game_over = false
    end

    def width
      GRID_WIDTH * BLOCK_SIZE
    end

    def height
      GRID_HEIGHT * BLOCK_SIZE
    end

    def place(tetromino : Tetromino)
      tetromino.cells.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          next if cell.empty?

          set_cell(
            grid_x: tetromino.grid_x + column_index,
            grid_y: tetromino.grid_y + row_index,
            shape: cell.shape
          )
        end
      end
    end

    def new_tetromino
      Tetromino.new(grid_x: 3, grid_y: 0, shape: Shape.random)
    end

    def set_cell(grid_x, grid_y, shape : Shape)
      @cells[grid_y][grid_x].shape = shape
    end

    def update
      update_tetromino

      clear_lines
    end

    def update_tetromino
      delta_x = delta_y = 0
      frame_time = LibRay.get_frame_time

      # keys
      # left
      if LibRay.key_down?(LibRay::KEY_LEFT) || LibRay.key_down?(LibRay::KEY_A)
        @key_down_initial_timer.increase(frame_time)

        if @key_down_initial_timer.done?
          @key_down_timer.increase(frame_time)

          if @key_down_timer.done?
            delta_x -= 1
            @key_down_timer.reset
          end
        elsif LibRay.key_pressed?(LibRay::KEY_LEFT) || LibRay.key_pressed?(LibRay::KEY_A)
          delta_x -= 1
        end
      elsif LibRay.key_released?(LibRay::KEY_LEFT) || LibRay.key_released?(LibRay::KEY_A)
        @key_down_initial_timer.reset
      end

      # right
      if LibRay.key_down?(LibRay::KEY_RIGHT) || LibRay.key_down?(LibRay::KEY_D)
        @key_down_initial_timer.increase(frame_time)

        if @key_down_initial_timer.done?
          @key_down_timer.increase(frame_time)

          if @key_down_timer.done?
            delta_x += 1
            @key_down_timer.reset
          end
        elsif LibRay.key_pressed?(LibRay::KEY_RIGHT) || LibRay.key_pressed?(LibRay::KEY_D)
          delta_x += 1
        end
      elsif LibRay.key_released?(LibRay::KEY_RIGHT) || LibRay.key_released?(LibRay::KEY_D)
        @key_down_initial_timer.reset
      end

      # down
      if LibRay.key_down?(LibRay::KEY_DOWN) || LibRay.key_down?(LibRay::KEY_S)
        @key_down_timer.increase(frame_time * KEY_DOWN_SOFT_DROP_RATE)

        if @key_down_timer.done?
          delta_y += 1

          @key_down_timer.reset
        end
      end

      # rotate
      counter_rotation = :none
      if LibRay.key_pressed?(LibRay::KEY_LEFT_SHIFT)
        @tetromino.rotate(:counter_clockwise)
        counter_rotation = :clockwise
      elsif LibRay.key_pressed?(LibRay::KEY_RIGHT_SHIFT) || LibRay.key_pressed?(LibRay::KEY_UP)
        @tetromino.rotate(:clockwise)
        counter_rotation = :counter_clockwise
      end

      # drop timer
      if delta_y == 0 && (@drop_timer.done? || @blocked_timer.active?)
        delta_y += 1
        @drop_timer.reset

        if counter_rotation != :none
          delta_y -= 1
        end
      else
        @drop_timer.increase(frame_time)
      end

      # adjust rotation
      if counter_rotation != :none
        set_tetromino_status(delta_x, delta_y)

        more_delta_y = 0

        # try to adjust
        if !@tetromino.status.free?
          more_delta_y = -1

          delta_y += more_delta_y
        end

        set_tetromino_status(delta_x, delta_y)

        # unadjust
        if !@tetromino.status.free?
          delta_y -= more_delta_y

          # unrotate
          @tetromino.rotate(counter_rotation)
          counter_rotation = :none
        end
      end

      # check tetromino movement
      set_tetromino_status(delta_x, delta_y)

      case @tetromino.status
      when .free?
        if (delta_x != 0 || counter_rotation != :none) && @blocked_timer.active?
          @blocked_timer.reset
        end

        @tetromino_did_move = true
        @tetromino.grid_x += delta_x
        @tetromino.grid_y += delta_y
      when .blocked?
        if @blocked_timer.done?
          @blocked_timer.reset
          place(@tetromino)
          tetromino = new_tetromino

          @tetromino_did_move = false

          if game_over_collision?(tetromino)
            @game_over = true
          else
            @tetromino = tetromino
          end
        else
          @blocked_timer.increase(frame_time)
        end
      when .collided?
        # don't do anything
        # maybe an alert color flash, vibration, or sound?
      end
    end

    def set_tetromino_status(delta_x, delta_y, tetromino = @tetromino)
      # TODO: switch to cells instead of `blocks` and use each_with_index
      tetromino.cells.each_with_index do |row, row_index|
        row.each_with_index do |tet_cell, column_index|
          next if tet_cell.empty?

          cell_y = tetromino.grid_y + row_index + delta_y
          cell_x = tetromino.grid_x + column_index + delta_x

          if cell_y < 0
            tetromino.collided
            return
          end

          if cell_y >= GRID_HEIGHT
            tetromino.blocked
            return
          end

          if cell_x < 0 || cell_x >= GRID_WIDTH
            tetromino.collided
            return
          end

          cell = @cells[cell_y][cell_x]
          next if cell.empty?

          if delta_x == 0
            tetromino.blocked
            return
          else
            tetromino.collided
            return
          end
        end
      end

      tetromino.free
    end

    def clear_lines
      lines_cleared = [] of Int32

      @cells.each_with_index do |row, row_index|
        if row.all? { |cell| !cell.empty? }
          lines_cleared << row_index
        end
      end

      lines_cleared.each_with_index do |line_cleared, line_cleared_index|
        @cells.delete_at(line_cleared - line_cleared_index)
      end

      lines_cleared.each do |_line_cleared|
        @cells.unshift(Array.new(GRID_WIDTH) { Cell.new(shape: Shape::Empty) })
      end
    end

    def game_over_collision?(tetromino)
      unless @tetromino_did_move
        set_tetromino_status(0, 0, tetromino)
        tetromino.status.blocked?
      else
        false
      end
    end

    def print
      puts "["
      @cells.each do |line|
        puts line.join
      end
      puts "]"
    end

    def draw
      @cells.each_with_index do |row, row_index|
        row.each_with_index do |cell, column_index|
          cell.draw(
            x: @x + column_index * BLOCK_SIZE,
            y: @y + row_index * BLOCK_SIZE,
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
