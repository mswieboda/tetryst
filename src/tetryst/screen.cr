module Tetryst
  class Screen
    getter? paused

    BOARD_BORDER_WIDTH = 10

    LINES_PER_LEVEL = 10

    def initialize(initial_level = 0)
      @board = Board.new(
        x: (Game::SCREEN_WIDTH / 2.0 - Board.width / 2.0).to_i,
        y: (Game::SCREEN_HEIGHT / 2.0 - Board.height / 2.0).to_i,
        level: initial_level
      )

      @level_label = Label.new(text: "Level: #{initial_level}")
      @level_label.x = @board.x - BOARD_BORDER_WIDTH - Board.width / 2
      @level_label.y = @board.y

      @lines_label = Label.new(text: "Lines: #{LINES_PER_LEVEL}")
      @lines_label.x = @board.x - BOARD_BORDER_WIDTH - Board.width / 2
      @lines_label.y = @level_label.y + @level_label.height

      @score_label = Label.new(text: "Score: 0")
      @score_label.x = @board.x - BOARD_BORDER_WIDTH - Board.width / 2
      @score_label.y = @lines_label.y + @level_label.height

      @paused = false
    end

    def pause
      @paused = true
    end

    def unpause
      @paused = false
    end

    def update
      unless paused?
        @board.update
        update_info
      end

      if @board.game_over?
        pause
      end
    end

    def update_info
      @level_label.text = "Level: #{@board.level}"
      @lines_label.text = "Lines: #{LINES_PER_LEVEL - @board.lines_cleared}"
      @score_label.text = "Score: #{@board.score}"
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

      # info
      @level_label.draw
      @lines_label.draw
      @score_label.draw

      # TODO: draw @board.next_tetrominos
    end
  end
end
