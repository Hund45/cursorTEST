// TouchDesigner Tesseract 4D Shader - Fresh Version
// Mind-blowing 4-dimensional hypercube visualization

uniform float uTime;
uniform vec3 uTD2DInfos[1];
in vec3 vUV;

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
    return mat4(c, 0, 0, -s, 0, 1, 0, 0, 0, 0, 1, 0, s, 0, 0, c);
}

mat4 rotateYZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(1, 0, 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1);
}

mat4 rotateXZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(c, 0, -s, 0, 0, 1, 0, 0, s, 0, c, 0, 0, 0, 0, 1);
}

mat4 rotateYW(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat4(1, 0, 0, 0, 0, c, 0, -s, 0, 0, 1, 0, 0, s, 0, c);
}

// 4D to 3D projection
vec3 project4Dto3D(vec4 p4d) {
    float w = 3.0;
    return p4d.xyz / (w - p4d.w);
}

// Distance to line segment
float distanceToSegment(vec3 p, vec3 a, vec3 b) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// Generate tesseract vertices
void getTesseractVertices(out vec4 vertices[16]) {
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

void main() {
    vec2 uv = vUV.xy;
    vec2 resolution = uTD2DInfos[0].xy;
    uv = (uv * resolution - 0.5 * resolution) / resolution.y;
    
    float t = uTime * uRotationSpeed;
    mat4 rot = rotateXW(t * 0.7) * rotateYZ(t * 0.5) * rotateXZ(t * 0.3) * rotateYW(t * 0.9);
    
    vec4 vertices[16];
    getTesseractVertices(vertices);
    
    vec3 projectedVertices[16];
    for(int i = 0; i < 16; i++) {
        vec4 rotated = rot * vertices[i];
        projectedVertices[i] = project4Dto3D(rotated);
    }
    
    vec3 rayDir = normalize(vec3(uv, 1.5));
    vec3 rayPos = vec3(0.0, 0.0, -5.0);
    
    float edgeGlow = 0.0;
    float vertGlow = 0.0;
    
    // Calculate glow from tesseract edges and vertices
    for(int i = 0; i < 16; i++) {
        // Ray marching for glow effect
        for(int step = 0; step < 48; step++) {
            vec3 p = rayPos + rayDir * float(step) * 0.1;
            
            // Distance to current vertex
            float vDist = length(p - projectedVertices[i]);
            if(vDist < 0.2) {
                vertGlow += 1.0 / (1.0 + vDist * 30.0) * 0.03;
            }
            
            // Distance to edges from this vertex
            if(i < 15) {
                vec3 a = projectedVertices[i];
                vec3 b = projectedVertices[i + 1];
                float eDist = distanceToSegment(p, a, b);
                if(eDist < 0.1) {
                    edgeGlow += 1.0 / (1.0 + eDist * 20.0) * 0.02;
                }
            }
        }
    }
    
    // Additional important tesseract edges
    int edges[24] = int[](
        0,1, 0,2, 0,4, 0,8,
        1,3, 1,5, 1,9,
        2,3, 2,6, 2,10,
        3,7, 3,11,
        4,5, 4,6, 4,12,
        5,7, 5,13,
        6,7, 6,14,
        7,15,
        8,9, 8,10, 8,12,
        9,11, 9,13,
        10,11
    );
    
    for(int i = 0; i < 12; i++) {
        vec3 a = projectedVertices[edges[i*2]];
        vec3 b = projectedVertices[edges[i*2 + 1]];
        
        for(int step = 0; step < 32; step++) {
            vec3 p = rayPos + rayDir * float(step) * 0.1;
            float dist = distanceToSegment(p, a, b);
            if(dist < 0.1) {
                edgeGlow += 1.0 / (1.0 + dist * 20.0) * 0.015;
            }
        }
    }
    
    // Background
    vec3 bgColor = vec3(0.05, 0.05, 0.1);
    float pattern = sin(length(uv) * 10.0 - uTime * 2.0) * 0.5 + 0.5;
    bgColor += vec3(0.02, 0.01, 0.03) * pattern;
    
    // Color mixing
    vec3 color1 = uColor1 * (sin(uTime * 2.0) * 0.5 + 0.5);
    vec3 color2 = uColor2 * (cos(uTime * 1.5) * 0.5 + 0.5);
    vec3 color3 = uColor3 * (sin(uTime * 3.0 + 1.0) * 0.5 + 0.5);
    
    // Final color
    vec3 finalColor = bgColor;
    finalColor += color1 * edgeGlow * uGlow;
    finalColor += color2 * edgeGlow * uGlow * 0.7;
    finalColor += color3 * vertGlow * uGlow * 2.0;
    
    // Effects
    finalColor += pow(edgeGlow + vertGlow, 2.0) * 0.3;
    finalColor = finalColor / (1.0 + finalColor);
    finalColor = pow(finalColor, vec3(0.4545));
    
    fragColor = vec4(finalColor, 1.0);
}