# Dodo Sphere

A SketchUp extension that lets you draw a sphere interactively — click to set the center, then drag or type the radius.

## Features

- **Click to place** the sphere center anywhere in the model
- **Drag** to set the radius with a live 3-axis preview (red, green, blue circles)
- **Type a value** in the VCB (Value Control Box) and press Enter for an exact radius
- **Escape** to restart from center selection without leaving the tool
- Stays active after each sphere so you can place multiple spheres in a row
- Sphere is created as a named Group (24-segment UV sphere)

## Installation

1. Download or clone this repository
2. Copy `dodo_sphere.rb` and the `dodo_sphere/` folder into your SketchUp Plugins directory:
   - **macOS:** `~/Library/Application Support/SketchUp <version>/SketchUp/Plugins/`
   - **Windows:** `%AppData%\SketchUp\SketchUp <version>\SketchUp\Plugins\`
3. Restart SketchUp
4. Go to **Window > Extension Manager** and enable **Dodo Sphere**

## Usage

1. Click **Draw > Dodo Sphere** from the menu bar, or use the toolbar button
2. Click anywhere in the viewport to set the sphere's center
3. Move the mouse to preview the sphere — the radius is shown in the VCB (bottom-right)
4. Either:
   - **Click** to confirm the radius at the current mouse position
   - **Type** a radius value and press Enter (e.g. `500mm`, `2m`, `1'6"`)
5. The sphere is created and the tool resets, ready for the next one

## Requirements

- SketchUp 2017 or later (uses the modern Ruby API)

## File Structure

```
dodo_sphere.rb           # Extension loader / registration
dodo_sphere/
  main.rb                # Menu and toolbar setup
  sphere_tool.rb         # Interactive tool (mouse + VCB input)
  sphere_creator.rb      # UV-sphere geometry builder
  icons/
    sphere_16.png        # Toolbar icon (16×16)
    sphere_24.png        # Toolbar icon (24×24)
```

## License

MIT — free to use, modify, and distribute.
