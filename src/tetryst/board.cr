module Tetryst
  class Board
    getter? game_over
    getter cells : Array(Array(Cell))
    getter x : Int32
    getter y : Int32
    getter level : Int32
    getter lines_cleared : Int32
    getter score : Int32

    @tetromino : Tetromino

    # in blocks
    GRID_WIDTH  = 10
    GRID_HEIGHT = 22

    # in pixels
    BLOCK_SIZE = ((Game::SCREEN_HEIGHT / GRID_HEIGHT) / 8).to_i * 8

    # in seconds
    DROP_TIME               =  0.5
    BLOCKED_TIME            =  0.2
    KEY_DOWN_INITIAL_TIME   =  0.2
    KEY_DOWN_TIME           = 0.06
    KEY_DOWN_SOFT_DROP_RATE =    2

    def initialize(@x = 0, @y = 0, @level = 0)
      @cells = Array.new(GRID_HEIGHT) { Array.new(GRID_WIDTH) { Cell.new } }
      @tetromino = new_tetromino
      @drop_timer = Timer.new(drop_time_from_level)
      @blocked_timer = Timer.new(BLOCKED_TIME)
      @key_down_initial_timer = Timer.new(KEY_DOWN_INITIAL_TIME)
      @key_down_timer = Timer.new(KEY_DOWN_TIME)
      @tetromino_did_move = false
      @tetromino_hard_drop = false
      @lines_cleared = 0
      @game_over = false
      @score = 0
    end

    def self.width
      GRID_WIDTH * BLOCK_SIZE
    end

    def self.height
      GRID_HEIGHT * BLOCK_SIZE
    end

    def drop_time_from_level
      (DROP_TIME - Math.log(1.0_f64 + @level / 30.0)).clamp(0, DROP_TIME)
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

      new_level if LibRay.key_pressed?(LibRay::KEY_R)

      clear_lines
    end

    def update_tetromino
      delta_x = delta_y = 0
      frame_time = LibRay.get_frame_time

      @tetromino.update_ghost(@cells)

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

      # soft drop
      if LibRay.key_down?(LibRay::KEY_DOWN) || LibRay.key_down?(LibRay::KEY_S)
        @key_down_timer.increase(frame_time * KEY_DOWN_SOFT_DROP_RATE)

        if @key_down_timer.done?
          delta_y += 1

          @key_down_timer.reset
        end
      end

      # hard drop
      if LibRay.key_pressed?(LibRay::KEY_SPACE)
        @tetromino.hard_drop
        @tetromino_hard_drop = true
      end

      # rotate
      counter_rotation = :none
      if LibRay.key_pressed?(LibRay::KEY_LEFT_SHIFT)
        @tetromino.rotate(:counter_clockwise)
        counter_rotation = :clockwise
      elsif LibRay.key_pressed?(LibRay::KEY_RIGHT_SHIFT) || LibRay.key_pressed?(LibRay::KEY_UP) || LibRay.key_pressed?(LibRay::KEY_W)
        @tetromino.rotate(:clockwise)
        counter_rotation = :counter_clockwise
      end

      # drop timer
      if delta_y == 0 && (@drop_timer.done? || @blocked_timer.active?) || @tetromino_hard_drop
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
        @tetromino.update_status(@cells, delta_x, delta_y)

        more_delta_y = 0

        # try to adjust
        if !@tetromino.status.free?
          more_delta_y = -1

          delta_y += more_delta_y
        end

        @tetromino.update_status(@cells, delta_x, delta_y)

        # unadjust
        if !@tetromino.status.free?
          delta_y -= more_delta_y

          # unrotate
          @tetromino.rotate(counter_rotation)
          counter_rotation = :none
        end
      end

      # check tetromino movement
      @tetromino.update_status(@cells, delta_x, delta_y)

      case @tetromino.status
      when .free?
        if (delta_x != 0 || counter_rotation != :none) && @blocked_timer.active?
          @blocked_timer.reset
        end

        @tetromino_did_move = true
        @tetromino.grid_x += delta_x
        @tetromino.grid_y += delta_y
      when .blocked?
        if @blocked_timer.done? || @tetromino_hard_drop
          @blocked_timer.reset
          @tetromino_hard_drop = false

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

      @lines_cleared += lines_cleared.size

      # add to score
      # 40 * (n + 1)  100 * (n + 1) 300 * (n + 1) 1200 * (n + 1)
      case lines_cleared.size
      when 1
        @score += 40 * (level + 1)
      when 2
        @score += 100 * (level + 1)
      when 3
        @score += 300 * (level + 1)
      when 4
        @score += 1200 * (level + 1)
      end

      new_level if @lines_cleared >= Screen::LINES_PER_LEVEL
    end

    def new_level
      @lines_cleared = 0
      @level += 1
      @drop_timer = Timer.new(drop_time_from_level)
    end

    def game_over_collision?(tetromino)
      unless @tetromino_did_move
        tetromino.update_status(@cells)
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
    end
  end
end
