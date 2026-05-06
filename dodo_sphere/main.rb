require_relative 'sphere_creator'
require_relative 'sphere_tool'

module DodoTools
  module Sphere
    unless @loaded
      @loaded = true

      # ── Menu entry ─────────────────────────────────────────────────
      menu = UI.menu('Draw')
      menu.add_item('Dodo Sphere') { Sketchup.active_model.select_tool(SphereTool.new) }

      # ── Toolbar ────────────────────────────────────────────────────
      toolbar = UI::Toolbar.new('Dodo Sphere')

      cmd = UI::Command.new('Sphere') { Sketchup.active_model.select_tool(SphereTool.new) }
      cmd.tooltip         = 'Dodo Sphere — click center, drag or type radius'
      cmd.status_bar_text = 'Draw a sphere'

      icon_dir = File.join(__dir__, 'icons')
      if File.exist?(File.join(icon_dir, 'sphere_16.png'))
        cmd.small_icon = File.join(icon_dir, 'sphere_16.png')
        cmd.large_icon = File.join(icon_dir, 'sphere_24.png')
      end

      toolbar.add_item(cmd)
      toolbar.restore
    end
  end
end
