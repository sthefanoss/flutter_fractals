#version 320 es

precision highp float;

layout(location = 0) out vec4 fragColor;

layout(location = 0) uniform vec3 color1;
layout(location = 1) uniform vec3 color2;
layout(location = 2) uniform float someValue;
layout(location = 3) uniform vec2 size;

void main () {
    vec4 p = gl_FragCoord[0];
    fragColor = vec4(1.0,1.0,1.0*cos(), 1.0);

}