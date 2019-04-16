module Tetryst
  class Game
    SCREEN_WIDTH  = 1024
    SCREEN_HEIGHT =  768

    DEBUG = false

    TARGET_FPS = 60
    DRAW_FPS   = DEBUG

    def initialize
      LibRay.init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Tetryst")
      LibRay.set_target_fps(TARGET_FPS)

      @tetromino = Tetronimo.new(0, 0, Shape::T)
      @tetromino.print
      @tetromino.rotate(direction: :counter_clockwise)
      @tetromino.print

      @board = Board.new
      @board.set_cell(3, 21, Cell.new(Shape::Z))
      @board.print

      @paused = false
    end

    def pause
      @paused = true
    end

    def unpause
      @paused = false
    end

    def run
      while !LibRay.window_should_close?
        update
        draw_init
      end

      close
    end

    def update
    end

    def draw
      LibRay.draw_fps(0, 0) if DRAW_FPS
    end

    def draw_init
      LibRay.begin_drawing
      LibRay.clear_background LibRay::BLACK

      draw

      LibRay.end_drawing
    end

    def close
      LibRay.close_window
    end
  end
end
