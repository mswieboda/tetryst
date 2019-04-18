module Tetryst
  class Screen
    getter? paused

    def initialize
      @board = Board.new(
        x: Game::SCREEN_WIDTH / 2 - Board.width / 2,
        y: Game::SCREEN_HEIGHT / 2 - Board.height / 2
      )
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
    end
  end
end
