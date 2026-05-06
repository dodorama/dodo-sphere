# Dodo Sphere — SketchUp Extension loader
# Creates a sphere interactively via mouse or keyboard input.

require 'sketchup'
require 'extensions'

module DodoTools
  module Sphere
    EXTENSION = SketchupExtension.new(
      'Dodo Sphere',
      File.join(__dir__, 'dodo_sphere', 'main.rb')
    )
    EXTENSION.version     = '1.0.0'
    EXTENSION.creator     = 'Dodo / Riviera Studio'
    EXTENSION.description = 'Draw a sphere by clicking a center then dragging or typing the radius.'
    EXTENSION.copyright   = "© #{Time.now.year} Riviera Studio"

    Sketchup.register_extension(EXTENSION, true)
  end
end
