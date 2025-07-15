// TouchDesigner Tesseract 4D Shader
// A mind-blowing 4-dimensional hypercube visualization
// Pixel Shader

// TouchDesigner provides these automatically
uniform float uTime;
uniform vec3 uTD2DInfos[1];
in Vertex {
    vec4 color;
    vec3 worldSpacePos;
    vec3 texCoord0;
    flat int cameraIndex;
} iVert;

// Custom uniforms - add these in the Uniform page
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
void getTesseractVertices(out vec4 vertices[16]) {
    // Generate all 16 vertices of a tesseract (4D cube)
    int i = 0;
    for(int x = 0; x < 2; x++) {
        for(int y = 0; y < 2; y++) {
            for(int z = 0; z < 2; z++) {
                for(int w = 0; w < 2; w++) {
                    vertices[i] = vec4(
                        float(x) * 2.0 - 1.0,
                        float(y) * 2.0 - 1.0,
                        float(z) * 2.0 - 1.0,
                        float(w) * 2.0 - 1.0
                    ) * uSize;
                    i++;
                }
            }
        }
    }
}

// Fractal noise for extra visual flair
float noise(vec3 p) {
    return sin(p.x) * sin(p.y) * sin(p.z) * 0.5 + 0.5;
}

void main() {
    // Get UV coordinates from TouchDesigner
    vec2 uv = iVert.texCoord0.st;
    vec2 resolution = uTD2DInfos[0].xy;
    uv = (uv * resolution - 0.5 * resolution) / resolution.y;
    
    // Time-based rotations for different 4D planes
    float t = uTime * uRotationSpeed;
    mat4 rot = rotateXW(t * 0.7) * rotateYZ(t * 0.5) * rotateXZ(t * 0.3) * rotateYW(t * 0.9);
    
    // Get tesseract vertices
    vec4 vertices[16];
    getTesseractVertices(vertices);
    
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
    
    // Define tesseract edges connectivity
    int edges[32];
    edges[0] = 0; edges[1] = 1;    // Edge 0
    edges[2] = 0; edges[3] = 2;    // Edge 1
    edges[4] = 0; edges[5] = 4;    // Edge 2
    edges[6] = 0; edges[7] = 8;    // Edge 3
    edges[8] = 1; edges[9] = 3;    // Edge 4
    edges[10] = 1; edges[11] = 5;  // Edge 5
    edges[12] = 1; edges[13] = 9;  // Edge 6
    edges[14] = 2; edges[15] = 3;  // Edge 7
    edges[16] = 2; edges[17] = 6;  // Edge 8
    edges[18] = 2; edges[19] = 10; // Edge 9
    edges[20] = 3; edges[21] = 7;  // Edge 10
    edges[22] = 3; edges[23] = 11; // Edge 11
    edges[24] = 4; edges[25] = 5;  // Edge 12
    edges[26] = 4; edges[27] = 6;  // Edge 13
    edges[28] = 4; edges[29] = 12; // Edge 14
    edges[30] = 5; edges[31] = 7;  // Edge 15
    
    // Calculate distance to edges (first 16 edges)
    for(int i = 0; i < 16; i++) {
        vec3 a = projectedVertices[edges[i*2]];
        vec3 b = projectedVertices[edges[i*2 + 1]];
        
        // Ray marching along the ray
        for(int step = 0; step < 64; step++) {
            vec3 p = rayPos + rayDir * float(step) * 0.1;
            float dist = distanceToSegment(p, a, b);
            
            if(dist < 0.1) {
                float intensity = 1.0 / (1.0 + dist * 20.0);
                edgeGlow += intensity * 0.02;
                minDist = min(minDist, dist);
            }
        }
    }
    
    // Continue with remaining edges
    int moreEdges[32];
    moreEdges[0] = 5; moreEdges[1] = 13;   // Edge 16
    moreEdges[2] = 6; moreEdges[3] = 7;    // Edge 17
    moreEdges[4] = 6; moreEdges[5] = 14;   // Edge 18
    moreEdges[6] = 7; moreEdges[7] = 15;   // Edge 19
    moreEdges[8] = 8; moreEdges[9] = 9;    // Edge 20
    moreEdges[10] = 8; moreEdges[11] = 10; // Edge 21
    moreEdges[12] = 8; moreEdges[13] = 12; // Edge 22
    moreEdges[14] = 9; moreEdges[15] = 11; // Edge 23
    moreEdges[16] = 9; moreEdges[17] = 13; // Edge 24
    moreEdges[18] = 10; moreEdges[19] = 11; // Edge 25
    moreEdges[20] = 10; moreEdges[21] = 14; // Edge 26
    moreEdges[22] = 11; moreEdges[23] = 15; // Edge 27
    moreEdges[24] = 12; moreEdges[25] = 13; // Edge 28
    moreEdges[26] = 12; moreEdges[27] = 14; // Edge 29
    moreEdges[28] = 13; moreEdges[29] = 15; // Edge 30
    moreEdges[30] = 14; moreEdges[31] = 15; // Edge 31
    
    for(int i = 0; i < 16; i++) {
        vec3 a = projectedVertices[moreEdges[i*2]];
        vec3 b = projectedVertices[moreEdges[i*2 + 1]];
        
        for(int step = 0; step < 64; step++) {
            vec3 p = rayPos + rayDir * float(step) * 0.1;
            float dist = distanceToSegment(p, a, b);
            
            if(dist < 0.1) {
                float intensity = 1.0 / (1.0 + dist * 20.0);
                edgeGlow += intensity * 0.02;
            }
        }
    }
    
    // Add vertex glowing spheres
    float vertexGlow = 0.0;
    for(int i = 0; i < 16; i++) {
        for(int step = 0; step < 32; step++) {
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
    float pattern = sin(length(uv) * 10.0 - uTime * 2.0) * 0.5 + 0.5;
    bgColor += vec3(0.02, 0.01, 0.03) * pattern;
    
    // Fractal noise overlay
    vec3 noisePos = vec3(uv * 5.0, uTime * 0.5);
    float n = noise(noisePos) * noise(noisePos * 2.0) * noise(noisePos * 4.0);
    bgColor += vec3(0.01, 0.005, 0.02) * n;
    
    // Color mixing based on position and time
    vec3 color1 = uColor1 * (sin(uTime * 2.0) * 0.5 + 0.5);
    vec3 color2 = uColor2 * (cos(uTime * 1.5) * 0.5 + 0.5);
    vec3 color3 = uColor3 * (sin(uTime * 3.0 + 1.0) * 0.5 + 0.5);
    
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
    
    fragColor = TDOutputSwizzle(vec4(finalColor, 1.0));
}