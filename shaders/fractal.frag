#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

layout(location=0) uniform float scale;
layout(location=1) uniform vec2 center;
layout(location=2) uniform vec2 resolution;

layout(location=0) out vec4 fragColor;

void main(){
    vec2 uv = FlutterFragCoord().xy / resolution.xy;
    vec2 z = vec2(0.0);
    vec2 c = vec2(1.0);
    float ii = 0.0;
    float oneThird = 1.0/3.0;
    float twoThirds = 2.0/3.0;
    c.x = (uv.x - 0.5) * scale - center.x;
    c.y = (uv.y - 0.5) * scale - center.y;
    for (float i=0.0;i<2.0;i+=0.0025) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;
        ii = 1.0- i;
        if((x * x + y * y) > 4.0) break;
        z.x = x;
        z.y = y;
    }
    if(ii > 0.5) ii = 1.0 - ii;
    float r =0.0;
    float g = 0.0;
    float b = 0.0;
    if(ii < oneThird) {
        r = ii * 3.0;
    } else if(ii < twoThirds) {
        r = 1.0;
        g = (ii-oneThird) * 3.0;
    } else {
        r = 1.0;
        g = 1.0;
        b = (ii-twoThirds) * 3.0;
    }
    fragColor = vec4(r,g,b ,1.0);
}