// Tesseract 4D Shader for TouchDesigner
// A mind-blowing 4-dimensional hypercube visualization
// By AI Assistant

uniform float time;
uniform vec2 resolution;
uniform float uRotationSpeed;
uniform float uSize;
uniform float uGlow;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;

out vec4 fragColor;

// 4D rotation matrices
mat4 rotateXW(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(
        c, 0, 0, -s,
        0, 1, 0, 0,
        0, 0, 1, 0,
        s, 0, 0, c
    );
}

mat4 rotateYZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(
        1, 0, 0, 0,
        0, c, -s, 0,
        0, s, c, 0,
        0, 0, 0, 1
    );
}

mat4 rotateXZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(
        c, 0, -s, 0,
        0, 1, 0, 0,
        s, 0, c, 0,
        0, 0, 0, 1
    );
}

mat4 rotateYW(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(
        1, 0, 0, 0,
        0, c, 0, -s,
        0, 0, 1, 0,
        0, s, 0, c
    );
}

// 4D to 3D projection
vec3 project4Dto3D(vec4 p4d) {
    float w = 3.0; // projection distance
    return p4d.xyz / (w - p4d.w);
}

// Distance to a line segment in 3D
float distanceToSegment(vec3 p, vec3 a, vec3 b) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// Generate tesseract vertices in 4D
vec4[16] getTesseractVertices() {
    vec4 vertices[16];
    
    // Generate all 16 vertices of a tesseract (4D cube)
    int i = 0;
    for(int x = 0; x < 2; x++) {
        for(int y = 0; y < 2; y++) {
            for(int z = 0; z < 2; z++) {
                for(int w = 0; w < 2; w++) {
                    vertices[i++] = vec4(
                        float(x) * 2.0 - 1.0,
                        float(y) * 2.0 - 1.0,
                        float(z) * 2.0 - 1.0,
                        float(w) * 2.0 - 1.0
                    ) * uSize;
                }
            }
        }
    }
    
    return vertices;
}

// Ray marching distance function for glowing effect
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

// Fractal noise for extra visual flair
float noise(vec3 p) {
    return sin(p.x) * sin(p.y) * sin(p.z) * 0.5 + 0.5;
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * resolution.xy) / resolution.y;
    
    // Time-based rotations for different 4D planes
    float t = time * uRotationSpeed;
    mat4 rot = rotateXW(t * 0.7) * rotateYZ(t * 0.5) * rotateXZ(t * 0.3) * rotateYW(t * 0.9);
    
    // Get tesseract vertices
    vec4 vertices[16] = getTesseractVertices();
    
    // Transform and project vertices to 3D
    vec3 projectedVertices[16];
    for(int i = 0; i < 16; i++) {
        vec4 rotated = rot * vertices[i];
        projectedVertices[i] = project4Dto3D(rotated);
    }
    
    // Ray marching setup
    vec3 rayDir = normalize(vec3(uv, 1.5));
    vec3 rayPos = vec3(0.0, 0.0, -5.0);
    
    float minDist = 1000.0;
    float edgeGlow = 0.0;
    
    // Define tesseract edges (each vertex connects to 4 others in 4D)
    int edges[32][2] = int[32][2](
        // Edges from vertex 0
        int[2](0, 1), int[2](0, 2), int[2](0, 4), int[2](0, 8),
        // Edges from vertex 1  
        int[2](1, 3), int[2](1, 5), int[2](1, 9),
        // Edges from vertex 2
        int[2](2, 3), int[2](2, 6), int[2](2, 10),
        // Edges from vertex 3
        int[2](3, 7), int[2](3, 11),
        // Edges from vertex 4
        int[2](4, 5), int[2](4, 6), int[2](4, 12),
        // Edges from vertex 5
        int[2](5, 7), int[2](5, 13),
        // Edges from vertex 6
        int[2](6, 7), int[2](6, 14),
        // Edges from vertex 7
        int[2](7, 15),
        // Edges from vertex 8
        int[2](8, 9), int[2](8, 10), int[2](8, 12),
        // Edges from vertex 9
        int[2](9, 11), int[2](9, 13),
        // Edges from vertex 10
        int[2](10, 11), int[2](10, 14),
        // Edges from vertex 11
        int[2](11, 15),
        // Edges from vertex 12
        int[2](12, 13), int[2](12, 14),
        // Edges from vertex 13
        int[2](13, 15),
        // Edges from vertex 14
        int[2](14, 15)
    );
    
    // Calculate distance to all edges
    for(int i = 0; i < 32; i++) {
        vec3 a = projectedVertices[edges[i][0]];
        vec3 b = projectedVertices[edges[i][1]];
        
        // Ray marching along the ray
        for(int step = 0; step < 100; step++) {
            vec3 p = rayPos + rayDir * float(step) * 0.1;
            float dist = distanceToSegment(p, a, b);
            
            if(dist < 0.1) {
                float intensity = 1.0 / (1.0 + dist * 20.0);
                edgeGlow += intensity * 0.02;
                minDist = min(minDist, dist);
            }
        }
    }
    
    // Add vertex glowing spheres
    float vertexGlow = 0.0;
    for(int i = 0; i < 16; i++) {
        for(int step = 0; step < 50; step++) {
            vec3 p = rayPos + rayDir * float(step) * 0.1;
            float dist = length(p - projectedVertices[i]);
            
            if(dist < 0.2) {
                float intensity = 1.0 / (1.0 + dist * 30.0);
                vertexGlow += intensity * 0.05;
            }
        }
    }
    
    // Create hypnotic background
    vec3 bgColor = vec3(0.05, 0.05, 0.1);
    float pattern = sin(length(uv) * 10.0 - time * 2.0) * 0.5 + 0.5;
    bgColor += vec3(0.02, 0.01, 0.03) * pattern;
    
    // Fractal noise overlay
    vec3 noisePos = vec3(uv * 5.0, time * 0.5);
    float n = noise(noisePos) * noise(noisePos * 2.0) * noise(noisePos * 4.0);
    bgColor += vec3(0.01, 0.005, 0.02) * n;
    
    // Color mixing based on position and time
    vec3 color1 = uColor1 * (sin(time * 2.0) * 0.5 + 0.5);
    vec3 color2 = uColor2 * (cos(time * 1.5) * 0.5 + 0.5);
    vec3 color3 = uColor3 * (sin(time * 3.0 + 1.0) * 0.5 + 0.5);
    
    // Combine all effects
    vec3 finalColor = bgColor;
    
    // Edge glow with color cycling
    finalColor += color1 * edgeGlow * uGlow;
    finalColor += color2 * edgeGlow * uGlow * 0.7;
    
    // Vertex glow
    finalColor += color3 * vertexGlow * uGlow * 2.0;
    
    // Add depth fog effect
    float depth = length(rayDir) * 0.1;
    finalColor *= exp(-depth * 0.1);
    
    // Bloom effect
    finalColor += pow(edgeGlow + vertexGlow, 2.0) * 0.3;
    
    // HDR tone mapping
    finalColor = finalColor / (1.0 + finalColor);
    
    // Gamma correction
    finalColor = pow(finalColor, vec3(0.4545));
    
    fragColor = vec4(finalColor, 1.0);
}