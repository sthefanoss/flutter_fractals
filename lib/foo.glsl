#version 320 es

precision highp float;

layout(location=0) out vec4 fragColor;

layout(location=0) uniform float scale;
layout(location=1) uniform vec2 center;

void main(){
    vec2 z = vec2(0.0);
    vec2 c = vec2(1.0);
    float ii = 0.0;
    c.x = 1.3333 * (gl_FragCoord.x - 0.5) * scale - center.x;
    c.y = (gl_FragCoord.y - 0.5) * scale - center.y;
    for (float i=0.0;i<0.99;i+=0.01) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;
        ii = i;
        if((x * x + y * y) > 4.0) break;
        z.x = x;
        z.y = y;
    }
//    vec3 color = vec3(1.0 - ii*0.01);
   fragColor = vec4(ii,ii,ii ,1.0);
}