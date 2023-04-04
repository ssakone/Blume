#version 100
precision mediump float;

varying highp vec2 qt_TexCoord0;
uniform sampler2D source;
uniform lowp float qt_Opacity;

void main() {
    lowp vec4 color = texture2D(source, qt_TexCoord0);
    lowp float luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
    // Utilisez une variable globale pour stocker la luminosité moyenne
    gl_FragColor = vec4(luminance, 0.0, 0.0, 1.0);
}
