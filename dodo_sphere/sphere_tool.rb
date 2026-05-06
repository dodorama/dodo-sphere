module DodoTools
  module Sphere
    class SphereTool
      # ── State machine ──────────────────────────────────────────────
      # :pick_center  → user clicks to set the center
      # :pick_radius  → user drags or types to set the radius, then clicks to confirm

      CURSOR_PENCIL = 632   # built-in SketchUp pencil cursor ID

      def initialize
        reset_state
      end

      # ── Tool lifecycle ─────────────────────────────────────────────

      def activate
        reset_state
        update_statusbar
        Sketchup.active_model.active_view.invalidate
      end

      def deactivate(view)
        view.invalidate
      end

      def resume(view)
        update_statusbar
        view.invalidate
      end

      def suspend(_view); end

      def onSetCursor
        UI.set_cursor(CURSOR_PENCIL)
      end

      # ── Mouse input ────────────────────────────────────────────────

      def onMouseMove(_flags, x, y, view)
        @ip.pick(view, x, y)
        @ip_current = @ip.position

        case @state
        when :pick_center
          # nothing extra — just track the cursor
        when :pick_radius
          @radius = @center.distance(@ip_current)
          Sketchup.vcb_value = format_length(@radius)
        end

        view.tooltip = @ip.tooltip
        view.invalidate
      end

      def onLButtonDown(_flags, x, y, view)
        @ip.pick(view, x, y)
        pt = @ip.position

        case @state
        when :pick_center
          @center = pt.clone
          @state  = :pick_radius
          update_statusbar
        when :pick_radius
          commit_sphere(view)
        end
      end

      # ── Keyboard / VCB input ───────────────────────────────────────

      def onUserText(text, view)
        return unless @state == :pick_radius

        parsed = parse_length(text)
        unless parsed
          UI.messagebox("Invalid radius: '#{text}'")
          return
        end

        if parsed <= 0
          UI.messagebox('Radius must be greater than zero.')
          return
        end

        @radius = parsed
        commit_sphere(view)
      end

      def onKeyDown(key, _repeat, _flags, view)
        if key == 27  # Escape
          if @state == :pick_radius
            reset_state
            update_statusbar
            view.invalidate
          else
            Sketchup.active_model.select_tool(nil)
          end
        end
      end

      # ── Drawing (OpenGL preview) ───────────────────────────────────

      def draw(view)
        draw_input_point(view)
        return unless @state == :pick_radius && @radius > 0

        draw_preview_circle(view, :red,   [1, 0, 0])
        draw_preview_circle(view, :green, [0, 1, 0])
        draw_preview_circle(view, :blue,  [0, 0, 1])
        draw_radius_line(view)
      end

      def getExtents
        bb = Geom::BoundingBox.new
        bb.add(@center) if @center
        if @center && @radius > 0
          r = @radius
          bb.add(Geom::Point3d.new(@center.x + r, @center.y, @center.z))
          bb.add(Geom::Point3d.new(@center.x - r, @center.y, @center.z))
          bb.add(Geom::Point3d.new(@center.x, @center.y + r, @center.z))
          bb.add(Geom::Point3d.new(@center.x, @center.y - r, @center.z))
          bb.add(Geom::Point3d.new(@center.x, @center.y, @center.z + r))
          bb.add(Geom::Point3d.new(@center.x, @center.y, @center.z - r))
        end
        bb
      end

      # ── VCB label ─────────────────────────────────────────────────

      def enableVCB?
        @state == :pick_radius
      end

      private

      # ── Helpers ────────────────────────────────────────────────────

      def reset_state
        @state      = :pick_center
        @center     = nil
        @radius     = 0
        @ip         = Sketchup::InputPoint.new
        @ip_current = nil
        Sketchup.vcb_label = 'Radius'
        Sketchup.vcb_value = ''
      end

      def commit_sphere(view)
        return if @radius <= 0

        SphereCreator.create(@center, @radius)

        # Keep tool active so user can draw another sphere immediately.
        reset_state
        update_statusbar
        view.invalidate
      end

      def update_statusbar
        case @state
        when :pick_center
          Sketchup.status_text = 'Click to set the sphere center.'
          Sketchup.vcb_label   = 'Radius'
          Sketchup.vcb_value   = ''
        when :pick_radius
          Sketchup.status_text = 'Drag or type a radius, then click or press Enter to create the sphere. Esc to restart.'
          Sketchup.vcb_label   = 'Radius'
        end
      end

      def draw_input_point(view)
        @ip.draw(view) if @ip.valid?
      end

      # Draws a circle of +radius+ around @center perpendicular to +axis+.
      CIRCLE_SEGS = 64

      def draw_preview_circle(view, _sym, color_rgb)
        return unless @center && @radius > 0

        # Choose two axes perpendicular to the named axis
        axes = {
          red:   [Geom::Vector3d.new(0, 1, 0), Geom::Vector3d.new(0, 0, 1)],
          green: [Geom::Vector3d.new(1, 0, 0), Geom::Vector3d.new(0, 0, 1)],
          blue:  [Geom::Vector3d.new(1, 0, 0), Geom::Vector3d.new(0, 1, 0)]
        }
        a1, a2 = axes[_sym]

        pts = (0..CIRCLE_SEGS).map do |i|
          angle = 2.0 * Math::PI * i / CIRCLE_SEGS
          Geom::Point3d.new(
            @center.x + @radius * (Math.cos(angle) * a1.x + Math.sin(angle) * a2.x),
            @center.y + @radius * (Math.cos(angle) * a1.y + Math.sin(angle) * a2.y),
            @center.z + @radius * (Math.cos(angle) * a1.z + Math.sin(angle) * a2.z)
          )
        end

        view.drawing_color = Sketchup::Color.new(*color_rgb.map { |c| (c * 200).to_i })
        view.line_width    = 1
        view.line_stipple  = ''
        view.draw(GL_LINE_STRIP, pts)
      end

      def draw_radius_line(view)
        return unless @center && @ip_current && @radius > 0

        view.drawing_color = Sketchup::Color.new(200, 200, 200)
        view.line_width    = 1
        view.line_stipple  = '_'
        view.draw(GL_LINES, [@center, @ip_current])
      end

      def format_length(inches)
        Sketchup.active_model.options['UnitsOptions']['LengthFormat']
        # Let SketchUp format it via Length
        inches.to_l.to_s
      end

      def parse_length(text)
        text.to_l
      rescue ArgumentError
        nil
      end
    end
  end
end
