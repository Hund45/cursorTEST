# TouchDesigner Setup Example

## Step-by-Step Tesseract 4D Setup

### 1. Create GLSL TOP
- Add `GLSL TOP` to your network
- Set resolution to `1920x1080` (or higher for better quality)

### 2. Load Shader File
- **GLSL** tab → **Pixel Shader**: `File`
- **File**: Browse to `tesseract_4d_touchdesigner.glsl`

### 3. Add Uniforms (Uniforms tab)
Click `+` for each uniform:

| Name | Type | Value | Description |
|------|------|-------|-------------|
| `uRotationSpeed` | `float` | `1.0` | How fast 4D rotations happen |
| `uSize` | `float` | `2.0` | Size of the tesseract |
| `uGlow` | `float` | `3.0` | Glow intensity |
| `uColor1` | `vec3` | `1.0, 0.2, 0.5` | Hot pink color |
| `uColor2` | `vec3` | `0.2, 0.8, 1.0` | Cyan color |
| `uColor3` | `vec3` | `0.8, 1.0, 0.2` | Electric green color |

### 4. That's it! 
You should now see a mind-blowing 4D tesseract rotating in real-time!

---

## Step-by-Step Mandelbulb Setup

### 1. Create GLSL TOP
- Add another `GLSL TOP` to your network
- Set resolution to `1920x1080` or higher

### 2. Load Shader File
- **GLSL** tab → **Pixel Shader**: `File`
- **File**: Browse to `mandelbulb_touchdesigner.glsl`

### 3. Add Uniforms (Uniforms tab)
Click `+` for each uniform:

| Name | Type | Value | Description |
|------|------|-------|-------------|
| `uPower` | `float` | `8.0` | Fractal complexity (try 6-12) |
| `uZoom` | `float` | `1.0` | Camera distance |
| `uSpeed` | `float` | `0.5` | Animation speed |
| `uColorShift` | `float` | `1.5` | Color cycling speed |

### 4. Enjoy the trip!
You'll see an infinite 3D fractal with flowing, organic shapes!

---

## Pro Tips

### Making it Interactive:
1. **Add sliders**: Use `Slider COMP` → connect to uniform values
2. **Audio reactive**: `Audio Device In CHOP` → `Audio Analysis CHOP` → connect to uniforms
3. **MIDI control**: `MIDI In CHOP` → `Math CHOP` (to scale 0-127 to your range) → uniforms

### Performance optimization:
- Start with 1080p, increase resolution if your GPU can handle it
- Both shaders are GPU-intensive - make sure you have decent graphics card
- If performance is slow, try reducing MAX_STEPS in the shader code

### Combining effects:
- Use `Composite TOP` to blend both shaders
- Add `Blur TOP` for extra bloom
- Use `Level TOP` for color grading
- Try `Feedback TOP` for recursive effects

### Values to try:

**Tesseract experiments:**
- `uRotationSpeed`: `0.1` (slow hypnotic), `3.0` (fast crazy)
- `uSize`: `0.5` (tiny), `5.0` (huge)
- `uGlow`: `1.0` (subtle), `10.0` (nuclear)

**Mandelbulb experiments:**
- `uPower`: `6.0` (simple), `12.0` (complex), `20.0` (insane)
- `uZoom`: `0.2` (inside fractal), `3.0` (far away view)
- `uSpeed`: `0.1` (slow drift), `2.0` (fast journey)