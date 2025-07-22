class CrystalWavesVisualizer {
    constructor() {
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.audioContext = null;
        this.analyser = null;
        this.dataArray = null;
        this.source = null;
        
        // Visual elements
        this.crystalMesh = null;
        this.particleSystem = null;
        this.crystalMaterial = null;
        this.demoGenerator = null;
        
        // Audio data
        this.frequencyData = new Uint8Array(256);
        this.sensitivity = 1.0;
        this.complexity = 3;
        
        // Performance tracking
        this.lastTime = 0;
        this.frameCount = 0;
        this.fps = 0;
        
        this.init();
        this.setupEventListeners();
    }
    
    init() {
        // Create scene
        this.scene = new THREE.Scene();
        this.scene.fog = new THREE.Fog(0x000000, 10, 100);
        
        // Create camera
        this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        this.camera.position.z = 15;
        this.camera.position.y = 5;
        
        // Create renderer
        this.renderer = new THREE.WebGLRenderer({ antialias: true });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setClearColor(0x000011);
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        
        document.getElementById('container').appendChild(this.renderer.domElement);
        
        this.createCrystalShader();
        this.createParticleSystem();
        this.createLighting();
        
        // Hide loading
        document.getElementById('loading').style.display = 'none';
        
        this.animate();
    }
    
    createCrystalShader() {
        // Custom vertex shader
        const vertexShader = `
            uniform float time;
            uniform float audioLevel;
            uniform float[32] frequencies;
            varying vec3 vPosition;
            varying vec3 vNormal;
            varying float vAudioInfluence;
            
            void main() {
                vPosition = position;
                vNormal = normal;
                
                // Calculate audio influence based on position
                float freqIndex = mod(position.y * 5.0 + 16.0, 32.0);
                float freq = frequencies[int(freqIndex)] / 255.0;
                vAudioInfluence = freq;
                
                // Displace vertices based on audio
                vec3 displaced = position;
                displaced += normal * freq * audioLevel * 2.0;
                
                // Add wave distortion
                displaced.x += sin(time * 2.0 + position.y * 0.5) * freq * 0.5;
                displaced.z += cos(time * 1.5 + position.x * 0.3) * freq * 0.5;
                
                gl_Position = projectionMatrix * modelViewMatrix * vec4(displaced, 1.0);
            }
        `;
        
        // Custom fragment shader
        const fragmentShader = `
            uniform float time;
            uniform float audioLevel;
            varying vec3 vPosition;
            varying vec3 vNormal;
            varying float vAudioInfluence;
            
            void main() {
                // Dynamic color based on audio and position
                vec3 color1 = vec3(0.1, 0.3, 1.0); // Blue
                vec3 color2 = vec3(1.0, 0.2, 0.5); // Pink
                vec3 color3 = vec3(0.2, 1.0, 0.3); // Green
                
                // Mix colors based on audio influence and position
                vec3 finalColor = mix(color1, color2, vAudioInfluence);
                finalColor = mix(finalColor, color3, sin(time + vPosition.y) * 0.5 + 0.5);
                
                // Add brightness based on audio level
                finalColor *= (1.0 + audioLevel * 2.0);
                
                // Add fresnel effect
                float fresnel = pow(1.0 - dot(normalize(vNormal), vec3(0.0, 0.0, 1.0)), 2.0);
                finalColor += fresnel * 0.5;
                
                gl_FragColor = vec4(finalColor, 0.8 + vAudioInfluence * 0.2);
            }
        `;
        
        // Create crystal geometry
        const geometry = new THREE.IcosahedronGeometry(5, 2);
        
        // Create shader material
        this.crystalMaterial = new THREE.ShaderMaterial({
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            uniforms: {
                time: { value: 0.0 },
                audioLevel: { value: 0.0 },
                frequencies: { value: new Array(32).fill(0) }
            },
            transparent: true,
            side: THREE.DoubleSide
        });
        
        this.crystalMesh = new THREE.Mesh(geometry, this.crystalMaterial);
        this.scene.add(this.crystalMesh);
    }
    
    createParticleSystem() {
        const particleCount = 1000;
        const positions = new Float32Array(particleCount * 3);
        const colors = new Float32Array(particleCount * 3);
        const sizes = new Float32Array(particleCount);
        
        for (let i = 0; i < particleCount; i++) {
            // Random sphere distribution
            const radius = 20 + Math.random() * 30;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.random() * Math.PI;
            
            positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i * 3 + 2] = radius * Math.cos(phi);
            
            colors[i * 3] = Math.random();
            colors[i * 3 + 1] = Math.random();
            colors[i * 3 + 2] = Math.random();
            
            sizes[i] = Math.random() * 5 + 1;
        }
        
        const particleGeometry = new THREE.BufferGeometry();
        particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        particleGeometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
        particleGeometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
        
        const particleMaterial = new THREE.ShaderMaterial({
            vertexShader: `
                attribute float size;
                attribute vec3 color;
                varying vec3 vColor;
                uniform float time;
                uniform float audioLevel;
                
                void main() {
                    vColor = color;
                    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
                    gl_Position = projectionMatrix * mvPosition;
                    gl_PointSize = size * (1.0 + audioLevel * 3.0) * (300.0 / -mvPosition.z);
                }
            `,
            fragmentShader: `
                varying vec3 vColor;
                
                void main() {
                    float distance = length(gl_PointCoord - vec2(0.5));
                    if (distance > 0.5) discard;
                    
                    float alpha = 1.0 - distance * 2.0;
                    gl_FragColor = vec4(vColor, alpha);
                }
            `,
            uniforms: {
                time: { value: 0.0 },
                audioLevel: { value: 0.0 }
            },
            transparent: true,
            blending: THREE.AdditiveBlending
        });
        
        this.particleSystem = new THREE.Points(particleGeometry, particleMaterial);
        this.scene.add(this.particleSystem);
    }
    
    createLighting() {
        // Ambient light
        const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
        this.scene.add(ambientLight);
        
        // Dynamic point lights
        const light1 = new THREE.PointLight(0xff6b6b, 1, 50);
        light1.position.set(10, 10, 10);
        this.scene.add(light1);
        
        const light2 = new THREE.PointLight(0x4ecdc4, 1, 50);
        light2.position.set(-10, -10, 10);
        this.scene.add(light2);
        
        const light3 = new THREE.PointLight(0x45b7d1, 1, 50);
        light3.position.set(0, 10, -10);
        this.scene.add(light3);
        
        // Store lights for animation
        this.lights = [light1, light2, light3];
    }
    
    setupAudio() {
        return new Promise((resolve, reject) => {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            this.analyser = this.audioContext.createAnalyser();
            this.analyser.fftSize = 512;
            this.analyser.smoothingTimeConstant = 0.8;
            this.dataArray = new Uint8Array(this.analyser.frequencyBinCount);
            resolve();
        });
    }
    
    async setupMicrophone() {
        try {
            await this.setupAudio();
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            this.source = this.audioContext.createMediaStreamSource(stream);
            this.source.connect(this.analyser);
            return true;
        } catch (error) {
            console.error('Microphone access denied:', error);
            return false;
        }
    }
    
    async setupAudioFile(file) {
        try {
            await this.setupAudio();
            const arrayBuffer = await file.arrayBuffer();
            const audioBuffer = await this.audioContext.decodeAudioData(arrayBuffer);
            
            if (this.source) {
                this.source.stop();
            }
            
            this.source = this.audioContext.createBufferSource();
            this.source.buffer = audioBuffer;
            this.source.loop = true;
            this.source.connect(this.analyser);
            this.source.connect(this.audioContext.destination);
            this.source.start();
            
            return true;
        } catch (error) {
            console.error('Error loading audio file:', error);
            return false;
        }
    }
    
    updateAudioData() {
        if (!this.analyser) return;
        
        this.analyser.getByteFrequencyData(this.dataArray);
        
        // Calculate average audio level
        let sum = 0;
        for (let i = 0; i < this.dataArray.length; i++) {
            sum += this.dataArray[i];
        }
        const avgLevel = (sum / this.dataArray.length) / 255.0 * this.sensitivity;
        
        // Update shader uniforms
        if (this.crystalMaterial) {
            this.crystalMaterial.uniforms.audioLevel.value = avgLevel;
            
            // Update frequency array for vertex shader
            const frequencies = new Array(32);
            for (let i = 0; i < 32; i++) {
                const index = Math.floor((i / 32) * this.dataArray.length);
                frequencies[i] = this.dataArray[index] || 0;
            }
            this.crystalMaterial.uniforms.frequencies.value = frequencies;
        }
        
        if (this.particleSystem && this.particleSystem.material) {
            this.particleSystem.material.uniforms.audioLevel.value = avgLevel;
        }
        
        // Update UI
        document.getElementById('audioLevel').textContent = Math.round(avgLevel * 100);
        
        return avgLevel;
    }
    
    animate() {
        requestAnimationFrame(() => this.animate());
        
        const currentTime = Date.now() * 0.001;
        const deltaTime = currentTime - this.lastTime;
        this.lastTime = currentTime;
        
        // Update FPS
        this.frameCount++;
        if (this.frameCount % 60 === 0) {
            this.fps = Math.round(1 / deltaTime);
            document.getElementById('fps').textContent = this.fps;
        }
        
        // Update audio data
        const audioLevel = this.updateAudioData();
        
        // Update shader time uniforms
        if (this.crystalMaterial) {
            this.crystalMaterial.uniforms.time.value = currentTime;
        }
        
        if (this.particleSystem && this.particleSystem.material) {
            this.particleSystem.material.uniforms.time.value = currentTime;
        }
        
        // Animate crystal rotation
        if (this.crystalMesh) {
            this.crystalMesh.rotation.x += 0.01 + audioLevel * 0.02;
            this.crystalMesh.rotation.y += 0.005 + audioLevel * 0.01;
            this.crystalMesh.rotation.z += 0.002 + audioLevel * 0.005;
        }
        
        // Animate particle system
        if (this.particleSystem) {
            this.particleSystem.rotation.y += 0.002 + audioLevel * 0.01;
        }
        
        // Animate lights
        if (this.lights) {
            this.lights.forEach((light, index) => {
                const time = currentTime + index * 2;
                light.position.x = Math.sin(time) * 15;
                light.position.z = Math.cos(time) * 15;
                light.intensity = 1 + audioLevel * 2;
            });
        }
        
        // Animate camera
        this.camera.position.x = Math.sin(currentTime * 0.1) * 3;
        this.camera.position.y = 5 + Math.cos(currentTime * 0.15) * 2;
        this.camera.lookAt(this.scene.position);
        
        this.renderer.render(this.scene, this.camera);
    }
    
    async setupDemoAudio() {
        try {
            await this.setupAudio();
            this.demoGenerator = new DemoAudioGenerator(this.audioContext, this.analyser);
            this.demoGenerator.start();
            return true;
        } catch (error) {
            console.error('Error setting up demo audio:', error);
            return false;
        }
    }
    
    setupEventListeners() {
        // Start audio button
        document.getElementById('startBtn').addEventListener('click', async () => {
            await this.setupAudio();
            document.getElementById('startBtn').disabled = true;
        });
        
        // Demo audio button
        document.getElementById('demoBtn').addEventListener('click', async () => {
            const success = await this.setupDemoAudio();
            if (success) {
                document.getElementById('demoBtn').disabled = true;
                document.getElementById('demoBtn').textContent = 'Demo Playing';
            }
        });
        
        // Microphone button
        document.getElementById('micBtn').addEventListener('click', async () => {
            const success = await this.setupMicrophone();
            if (success) {
                document.getElementById('micBtn').disabled = true;
                document.getElementById('micBtn').textContent = 'Microphone Active';
            }
        });
        
        // File input
        document.getElementById('fileBtn').addEventListener('click', () => {
            document.getElementById('audioFile').click();
        });
        
        document.getElementById('audioFile').addEventListener('change', async (event) => {
            const file = event.target.files[0];
            if (file) {
                const success = await this.setupAudioFile(file);
                if (success) {
                    document.getElementById('fileBtn').textContent = `Playing: ${file.name.substring(0, 20)}...`;
                }
            }
        });
        
        // Sensitivity control
        document.getElementById('sensitivity').addEventListener('input', (event) => {
            this.sensitivity = parseFloat(event.target.value);
        });
        
        // Complexity control
        document.getElementById('complexity').addEventListener('input', (event) => {
            this.complexity = parseInt(event.target.value);
            // You could use this to add/remove visual elements
        });
        
        // Window resize
        window.addEventListener('resize', () => {
            this.camera.aspect = window.innerWidth / window.innerHeight;
            this.camera.updateProjectionMatrix();
            this.renderer.setSize(window.innerWidth, window.innerHeight);
        });
    }
}

// Initialize the visualizer when the page loads
window.addEventListener('load', () => {
    new CrystalWavesVisualizer();
});