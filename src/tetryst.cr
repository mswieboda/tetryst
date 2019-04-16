require "cray"
require "./tetryst/*"

module Tetryst
  def self.run
    Game.new.run
  end
end

Tetryst.run
