// TouchDesigner Mandelbulb 3D Fractal Shader
// A mind-blowing journey through infinite fractal dimensions

// TouchDesigner provides these automatically
uniform float uTime;
uniform vec3 uTD2DInfos[1];

// Standard TouchDesigner inputs
in vec3 vUV;

// Custom uniforms - add these in the Uniform page
uniform float uPower;
uniform float uZoom;
uniform float uSpeed;
uniform float uColorShift;

out vec4 fragColor;

// Maximum ray marching iterations
#define MAX_STEPS 96
#define MAX_DIST 100.0
#define SURF_DIST 0.001

// Mandelbulb distance estimation
float mandelbulb(vec3 pos, float power) {
    vec3 z = pos;
    float dr = 1.0;
    float r = 0.0;
    
    for(int i = 0; i < 12; i++) {
        r = length(z);
        if(r > 2.0) break;
        
        // Convert to polar coordinates
        float theta = acos(z.z / r);
        float phi = atan(z.y, z.x);
        dr = pow(r, power - 1.0) * power * dr + 1.0;
        
        // Scale and rotate the point
        float zr = pow(r, power);
        theta = theta * power;
        phi = phi * power;
        
        // Convert back to cartesian coordinates
        z = zr * vec3(
            sin(theta) * cos(phi),
            sin(phi) * sin(theta),
            cos(theta)
        );
        z += pos;
    }
    
    return 0.5 * log(r) * r / dr;
}

// Scene distance function with multiple fractals and transformations
float sceneSDF(vec3 p) {
    // Apply time-based transformations
    float t = uTime * uSpeed;
    
    // Create multiple fractal instances with different transformations
    vec3 p1 = p;
    p1 = mat3(
        cos(t * 0.3), -sin(t * 0.3), 0,
        sin(t * 0.3), cos(t * 0.3), 0,
        0, 0, 1
    ) * p1;
    
    vec3 p2 = p;
    p2 = mat3(
        1, 0, 0,
        0, cos(t * 0.5), -sin(t * 0.5),
        0, sin(t * 0.5), cos(t * 0.5)
    ) * p2;
    
    vec3 p3 = p;
    p3 = mat3(
        cos(t * 0.7), 0, sin(t * 0.7),
        0, 1, 0,
        -sin(t * 0.7), 0, cos(t * 0.7)
    ) * p3;
    
    // Multiple mandelbulbs with different powers and positions
    float d1 = mandelbulb(p1 * 0.8, uPower);
    float d2 = mandelbulb((p2 + vec3(2.0 * sin(t), 0, 0)) * 0.6, uPower + 2.0);
    float d3 = mandelbulb((p3 + vec3(0, 2.0 * cos(t * 0.7), 2.0 * sin(t * 0.7))) * 0.4, uPower - 1.0);
    
    // Smooth minimum for organic blending
    float k = 0.3;
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    float blend12 = mix(d2, d1, h) - k * h * (1.0 - h);
    
    h = clamp(0.5 + 0.5 * (d3 - blend12) / k, 0.0, 1.0);
    float finalDist = mix(d3, blend12, h) - k * h * (1.0 - h);
    
    return finalDist * 0.7;
}

// Calculate normal using finite differences
vec3 getNormal(vec3 p) {
    float d = sceneSDF(p);
    vec2 e = vec2(0.001, 0);
    
    vec3 n = d - vec3(
        sceneSDF(p - e.xyy),
        sceneSDF(p - e.yxy),
        sceneSDF(p - e.yyx)
    );
    
    return normalize(n);
}

// Ray marching function
float rayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = sceneSDF(p);
        dO += dS;
        
        if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
    }
    
    return dO;
}

// Advanced lighting calculation
vec3 getLight(vec3 p, vec3 normal, vec3 viewDir, float t) {
    // Multiple dynamic light sources
    vec3 lightPos1 = vec3(4.0 * sin(t * 1.2), 3.0, 4.0 * cos(t * 1.2));
    vec3 lightPos2 = vec3(-3.0 * cos(t * 0.8), 4.0 * sin(t * 0.8), -2.0);
    vec3 lightPos3 = vec3(2.0 * sin(t * 1.5), -3.0 * cos(t * 1.5), 3.0);
    
    vec3 lightDir1 = normalize(lightPos1 - p);
    vec3 lightDir2 = normalize(lightPos2 - p);
    vec3 lightDir3 = normalize(lightPos3 - p);
    
    // Diffuse lighting
    float diff1 = clamp(dot(normal, lightDir1), 0.0, 1.0);
    float diff2 = clamp(dot(normal, lightDir2), 0.0, 1.0);
    float diff3 = clamp(dot(normal, lightDir3), 0.0, 1.0);
    
    // Specular lighting
    vec3 reflectDir1 = reflect(-lightDir1, normal);
    vec3 reflectDir2 = reflect(-lightDir2, normal);
    vec3 reflectDir3 = reflect(-lightDir3, normal);
    
    float spec1 = pow(clamp(dot(viewDir, reflectDir1), 0.0, 1.0), 32.0);
    float spec2 = pow(clamp(dot(viewDir, reflectDir2), 0.0, 1.0), 16.0);
    float spec3 = pow(clamp(dot(viewDir, reflectDir3), 0.0, 1.0), 64.0);
    
    // Color cycling for psychedelic effect
    vec3 color1 = vec3(
        0.8 + 0.2 * sin(t * uColorShift + p.x * 2.0),
        0.6 + 0.4 * cos(t * uColorShift * 1.3 + p.y * 3.0),
        0.7 + 0.3 * sin(t * uColorShift * 0.7 + p.z * 1.5)
    );
    
    vec3 color2 = vec3(
        0.5 + 0.5 * cos(t * uColorShift * 0.8 + p.z * 2.5),
        0.8 + 0.2 * sin(t * uColorShift * 1.1 + p.x * 1.8),
        0.6 + 0.4 * cos(t * uColorShift * 1.5 + p.y * 2.2)
    );
    
    vec3 color3 = vec3(
        0.7 + 0.3 * sin(t * uColorShift * 1.4 + p.y * 1.2),
        0.5 + 0.5 * cos(t * uColorShift * 0.9 + p.z * 2.8),
        0.9 + 0.1 * sin(t * uColorShift * 1.2 + p.x * 2.0)
    );
    
    // Combine lighting
    vec3 light = color1 * (diff1 + spec1 * 0.5);
    light += color2 * (diff2 + spec2 * 0.3);
    light += color3 * (diff3 + spec3 * 0.7);
    
    // Ambient occlusion approximation
    float ao = 1.0;
    float aoStepSize = 0.1;
    for(int i = 1; i <= 5; i++) {
        float dist = sceneSDF(p + normal * aoStepSize * float(i));
        ao *= 1.0 - max(0.0, (aoStepSize * float(i) - dist) * 0.2);
    }
    
    light *= ao;
    
    return light;
}

// Fog and atmosphere
vec3 applyFog(vec3 color, float dist, vec3 rayDir) {
    float fogAmount = 1.0 - exp(-dist * 0.02);
    vec3 fogColor = vec3(0.1, 0.05, 0.15) + vec3(0.05, 0.02, 0.08) * (rayDir.y * 0.5 + 0.5);
    return mix(color, fogColor, fogAmount);
}

void main() {
    // Get UV coordinates from TouchDesigner
    vec2 uv = vUV.xy;
    vec2 resolution = uTD2DInfos[0].xy;
    uv = (uv * resolution - 0.5 * resolution) / resolution.y;
    
    // Camera setup with smooth movement
    float t = uTime * uSpeed;
    vec3 ro = vec3(
        6.0 * cos(t * 0.3) * uZoom,
        4.0 * sin(t * 0.5) * uZoom,
        6.0 * sin(t * 0.2) * uZoom
    );
    
    vec3 target = vec3(
        2.0 * sin(t * 0.4),
        1.0 * cos(t * 0.6),
        2.0 * cos(t * 0.3)
    );
    
    vec3 forward = normalize(target - ro);
    vec3 right = normalize(cross(forward, vec3(0, 1, 0)));
    vec3 up = cross(right, forward);
    
    vec3 rd = normalize(forward + uv.x * right + uv.y * up);
    
    // Ray marching
    float d = rayMarch(ro, rd);
    
    vec3 color = vec3(0);
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 normal = getNormal(p);
        
        // Get lighting
        color = getLight(p, normal, -rd, t);
        
        // Apply fog
        color = applyFog(color, d, rd);
        
        // Add some rim lighting for extra glow
        float rim = 1.0 - max(0.0, dot(normal, -rd));
        color += pow(rim, 3.0) * vec3(0.3, 0.5, 0.8) * 0.5;
        
    } else {
        // Background with moving starfield
        vec3 bgColor = vec3(0.02, 0.01, 0.05);
        float stars = smoothstep(0.98, 1.0, sin(uv.x * 100.0 + t) * cos(uv.y * 100.0 - t));
        bgColor += stars * vec3(0.8, 0.9, 1.0) * 0.5;
        
        // Add some nebula-like effects
        float nebula = sin(uv.x * 5.0 + t * 0.5) * cos(uv.y * 3.0 - t * 0.3);
        bgColor += max(0.0, nebula) * vec3(0.2, 0.1, 0.3) * 0.3;
        
        color = bgColor;
    }
    
    // Enhance colors for psychedelic effect
    color = mix(color, sin(color * 6.28 + t * uColorShift) * 0.5 + 0.5, 0.1);
    
    // HDR tone mapping
    color = color / (1.0 + color);
    
    // Gamma correction
    color = pow(color, vec3(0.4545));
    
    // Add some chromatic aberration for extra trippy effect
    float aberration = length(uv) * 0.01;
    color.r = mix(color.r, pow(color.r, 1.1), aberration);
    color.b = mix(color.b, pow(color.b, 0.9), aberration);
    
    fragColor = vec4(color, 1.0);
}