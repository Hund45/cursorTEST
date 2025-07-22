# 🎵 Crystal Waves - 3D Sound Reactive Shader

A stunning 3D audio-reactive visualizer featuring morphing crystal formations, dynamic particle systems, and real-time shader effects that respond to sound.

## ✨ Features

- **3D Crystal Formation**: Interactive icosahedral geometry that morphs based on audio frequency data
- **Custom GLSL Shaders**: Real-time vertex and fragment shaders for dynamic visual effects
- **Particle System**: 1000+ particles that react to audio levels with additive blending
- **Dynamic Lighting**: Three animated point lights that respond to sound intensity
- **Multiple Audio Sources**: Support for microphone input, audio file upload, or demo audio
- **Real-time Controls**: Adjustable sensitivity and complexity settings
- **Performance Monitoring**: FPS counter and audio level indicators

## 🚀 Quick Start

1. Open `index.html` in a modern web browser
2. Click "Demo Audio" for instant visualization with generated sound
3. Or click "Use Microphone" to visualize real-time audio (requires permission)
4. Or click "Load Audio File" to upload your own music

## 🎛️ Controls

- **Demo Audio**: Generates synthetic audio with harmonics and frequency sweeps
- **Use Microphone**: Visualizes audio from your device's microphone
- **Load Audio File**: Upload MP3, WAV, or other audio files
- **Sensitivity**: Adjusts how reactive the visuals are to audio (0.1-3.0)
- **Complexity**: Controls visual complexity (1-5, currently affects future features)

## 🎨 Visual Elements

### Crystal Shader
- **Vertex Displacement**: Vertices move based on frequency data
- **Dynamic Colors**: Blue, pink, and green color mixing based on audio
- **Wave Distortion**: Sinusoidal displacement creates fluid motion
- **Fresnel Effect**: Edge highlighting for crystal-like appearance

### Particle System
- **1000 Particles**: Randomly distributed in 3D space
- **Size Scaling**: Particle size increases with audio level
- **Color Variation**: Random colors with alpha blending
- **Orbital Motion**: Slow rotation around the central crystal

### Lighting System
- **Ambient Lighting**: Base illumination
- **Three Point Lights**: Red, cyan, and blue lights that orbit and pulse
- **Dynamic Intensity**: Light brightness responds to audio levels

## 🔧 Technical Details

- **Framework**: Three.js for 3D rendering
- **Audio Processing**: Web Audio API with FFT analysis
- **Shaders**: Custom GLSL vertex and fragment shaders
- **Performance**: 60 FPS target with real-time audio analysis
- **Browser Support**: Modern browsers with WebGL support

## 🎵 Audio Processing

The visualizer uses the Web Audio API to:
- Perform real-time FFT analysis (512 sample size)
- Extract 256 frequency bins
- Calculate average audio levels
- Map frequency data to visual parameters
- Apply smoothing for stable animations

## 🔥 Cool Features

- **Frequency Mapping**: Different parts of the crystal respond to different frequency ranges
- **Camera Animation**: Smooth orbital camera movement
- **Responsive Design**: Adapts to window resizing
- **No Dependencies**: Everything runs in the browser
- **Visual Feedback**: Real-time FPS and audio level display

## 🌟 Perfect For

- Music visualization
- Live performances
- Audio analysis demonstrations
- WebGL/shader learning
- Interactive art installations

Enjoy the visual journey! 🚀✨