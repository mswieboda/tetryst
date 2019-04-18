module Tetryst
  class Screen
    getter? paused

    BOARD_BORDER_WIDTH = 10

    def initialize
      @board = Board.new(
        x: (Game::SCREEN_WIDTH / 2.0 - Board.width / 2.0).to_i,
        y: (Game::SCREEN_HEIGHT / 2.0 - Board.height / 2.0).to_i
      )

      @lines_label = Label.new(text: "Lines: 0")
      @lines_label.x = @board.x - BOARD_BORDER_WIDTH - Board.width / 2
      @lines_label.y = @board.y

      @paused = false
    end

    def pause
      @paused = true
    end

    def unpause
      @paused = false
    end

    def update
      @board.update unless paused?

      if @board.game_over?
        pause
      end
    end

    def draw
      @board.draw

      # border around board
      BOARD_BORDER_WIDTH.times do |border|
        LibRay.draw_rectangle_lines(
          pos_x: @board.x - border,
          pos_y: @board.y - border,
          width: Board.width + border * 2,
          height: Board.height + border * 2,
          color: LibRay::WHITE
        )
      end

      @lines_label.draw
    end
  end
end
