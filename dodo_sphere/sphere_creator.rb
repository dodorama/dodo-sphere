module DodoTools
  module Sphere
    module SphereCreator
      # Number of segments along each axis. Higher = smoother but heavier.
      SEGMENTS = 24

      # Builds a UV-sphere at +center+ with +radius+ inside a new Group.
      # Returns the created Group.
      def self.create(center, radius)
        model     = Sketchup.active_model
        entities  = model.active_entities

        model.start_operation('Create Sphere', true)

        group    = entities.add_group
        g_ents   = group.entities

        lat_segs = SEGMENTS       # latitude  rings  (pole-to-pole slices)
        lon_segs = SEGMENTS       # longitude columns (around the equator)

        # Build vertex grid: [lat][lon] → Geom::Point3d in group-local space
        # (group origin == sphere center, so local == world − center)
        verts = Array.new(lat_segs + 1) do |i|
          theta = Math::PI * i / lat_segs   # 0 (north pole) → π (south pole)
          Array.new(lon_segs) do |j|
            phi = 2.0 * Math::PI * j / lon_segs
            x   = radius * Math.sin(theta) * Math.cos(phi)
            y   = radius * Math.sin(theta) * Math.sin(phi)
            z   = radius * Math.cos(theta)
            Geom::Point3d.new(x, y, z)
          end
        end

        # Add quad (or triangle at poles) faces
        (0...lat_segs).each do |i|
          (0...lon_segs).each do |j|
            j_next = (j + 1) % lon_segs

            p00 = verts[i][j]
            p01 = verts[i][j_next]
            p10 = verts[i + 1][j]
            p11 = verts[i + 1][j_next]

            if i == 0
              # North-pole triangle
              g_ents.add_face(p00, p11, p10) rescue nil
            elsif i == lat_segs - 1
              # South-pole triangle
              g_ents.add_face(p00, p01, p11) rescue nil
            else
              # Regular quad (two triangles)
              g_ents.add_face(p00, p01, p11, p10) rescue nil
            end
          end
        end

        # Move group to the chosen center point
        tr = Geom::Transformation.translation(center)
        group.transformation = tr

        model.commit_operation
        group
      end
    end
  end
end
