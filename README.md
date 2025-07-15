# Mind-Blowing TouchDesigner Shaders

## Overview
This collection contains two incredible shaders that will blow your mind:

1. **Tesseract 4D Shader** (`tesseract_4d_touchdesigner.glsl`) - A genuine 4-dimensional hypercube rotating through 4D space
2. **Mandelbulb Fractal Shader** (`mandelbulb_touchdesigner.glsl`) - A 3D fractal with infinite detail and trippy effects

**✅ These are now properly formatted for TouchDesigner!** They use the correct TouchDesigner GLSL syntax with `uTime`, `uTD2DInfos`, `iVert`, and `TDOutputSwizzle()`.

## Quick Start (TL;DR)

1. **Add a GLSL TOP** in TouchDesigner
2. **Load shader**: Set Pixel Shader to File → browse to `.glsl` file
3. **Add uniforms**: Go to Uniforms page → click `+` → add the custom uniforms listed below
4. **Watch your mind get blown!** 🤯

## Detailed Setup Instructions

### 1. Tesseract 4D Shader Setup

1. **Create a GLSL TOP**:
   - Add a `GLSL TOP` node to your network
   - Set the resolution to at least 1920x1080 for best quality

2. **Load the Shader**:
   - In the GLSL TOP parameters, go to the `GLSL` tab
   - Set `Pixel Shader` to `File`
   - Browse and select `tesseract_4d_touchdesigner.glsl`

3. **Set up Custom Uniforms** (Uniforms page):
   - Click the `+` button to add custom uniforms:
   - `uRotationSpeed` → Type: `float`, Value: `1.0` (controls rotation speed)
   - `uSize` → Type: `float`, Value: `2.0` (controls tesseract size)
   - `uGlow` → Type: `float`, Value: `3.0` (controls glow intensity)
   - `uColor1` → Type: `vec3`, Value: `1.0, 0.2, 0.5` (first color)
   - `uColor2` → Type: `vec3`, Value: `0.2, 0.8, 1.0` (second color)
   - `uColor3` → Type: `vec3`, Value: `0.8, 1.0, 0.2` (third color)

4. **Built-in TouchDesigner Variables** (automatically provided):
   - `uTime` → Automatically connected to TouchDesigner's time
   - `uTD2DInfos[0]` → Automatically provides resolution info

### 2. Mandelbulb Fractal Shader Setup

1. **Create a GLSL TOP**:
   - Add another `GLSL TOP` node
   - Set high resolution for maximum detail

2. **Load the Shader**:
   - Set `Pixel Shader` to `File`
   - Browse and select `mandelbulb_touchdesigner.glsl`

3. **Set up Custom Uniforms** (Uniforms page):
   - Click the `+` button to add custom uniforms:
   - `uPower` → Type: `float`, Value: `8.0` (fractal power, try 6.0-12.0)
   - `uZoom` → Type: `float`, Value: `1.0` (camera zoom, try 0.5-2.0)
   - `uSpeed` → Type: `float`, Value: `0.5` (animation speed, try 0.3-1.0)
   - `uColorShift` → Type: `float`, Value: `1.5` (color cycling speed, try 1.0-3.0)

## Controls & Customization

### Tesseract 4D Controls:
- **uRotationSpeed**: Controls how fast the 4D rotations happen
- **uSize**: Makes the tesseract larger/smaller
- **uGlow**: Intensity of the edge and vertex glow effects
- **uColor1/2/3**: RGB values for the three main colors used

### Interactive Ideas:
- **Audio Reactive**: Connect uniform values to `Audio Device In CHOP` → `Audio Analysis CHOP`
- **MIDI Control**: Use `MIDI In CHOP` to control `uGlow`, colors, and rotation speed
- **LFO Effects**: Connect `LFO CHOP` to `uSize` for pulsing tesseract
- **Mouse/Touch**: Use `Mouse In CHOP` or `Touch In TOP` to control parameters
- **OSC Control**: Use `OSC In CHOP` for external control from phones/tablets

### Mandelbulb Controls:
- **uPower**: Changes the fractal formula (higher = more complex)
- **uZoom**: Camera distance from the fractal
- **uSpeed**: How fast the camera moves through the fractal
- **uColorShift**: Speed of color cycling

## Performance Tips

1. **Resolution**: Start with 1920x1080, increase for higher quality
2. **Ray Marching Steps**: Both shaders use ray marching - you can optimize by reducing steps in the shader code
3. **GPU**: These shaders are GPU-intensive, ensure good graphics card
4. **Cooling**: Extended use may heat up your GPU

## Advanced Usage

### Combining Effects:
- Use `Composite TOP` to blend both shaders
- Apply `Level TOP` for HDR adjustments
- Add `Blur TOP` for additional bloom effects
- Use `Transform TOP` for additional movement

### Audio Reactivity:
```python
# Example audio reactive setup for tesseract rotation
audio_level = op('audioanalysis')['chan1']
rotation_speed = 0.5 + audio_level * 2.0
```

### MIDI Control:
- Map MIDI CC values to shader uniforms
- Use `Math CHOP` to scale MIDI values appropriately
- Create presets with different parameter combinations

## Troubleshooting

1. **Shader not loading**: Check file path and GLSL syntax
2. **Black screen**: Verify all uniforms are properly connected
3. **Performance issues**: Reduce resolution or ray marching steps
4. **Colors not showing**: Check uniform color values are between 0.0-1.0

## What Makes These Special

### Tesseract 4D:
- **Genuine 4D geometry**: This isn't a fake effect - it's a real 4-dimensional object
- **4D rotations**: Rotates in XW, YZ, XZ, and YW planes simultaneously  
- **Hypercube projection**: Projects the 4D structure into our 3D view
- **32 edges, 16 vertices**: Complete tesseract topology

### Mandelbulb:
- **3D Mandelbrot**: Extension of the famous Mandelbrot set into 3D
- **Infinite detail**: Fractal nature means infinite zoom capability
- **Ray marching**: Real-time 3D volumetric rendering
- **Trippy visuals**: Organic, flowing, otherworldly shapes

Enjoy exploring these mind-bending mathematical visualizations!