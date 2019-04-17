module Tetryst
  class Game
    getter? paused

    SCREEN_WIDTH  = 1024
    SCREEN_HEIGHT =  768

    DEBUG = false

    TARGET_FPS = 60
    DRAW_FPS   = DEBUG

    def initialize
      LibRay.init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Tetryst")
      LibRay.set_target_fps(TARGET_FPS)

      @board = Board.new(x: SCREEN_WIDTH / 2 - Board.width / 2, y: SCREEN_HEIGHT - Board.height)
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
      @board.update unless paused?

      if @board.game_over?
        pause
      end
    end

    def draw
      @board.draw

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
