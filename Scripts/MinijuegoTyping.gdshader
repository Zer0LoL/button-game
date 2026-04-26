shader_type canvas_item;

// Le pedimos a Godot que lea lo que se está renderizando en la pantalla
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float light : hint_range(0.0, 100.0) = 15.0; // Subí un poco la luz base para que no empiece negro

vec3 vignette(vec3 rgb, vec2 uv){
    vec2 mask_2d = uv * (1.0 - uv.yx); 
    float vig = pow(mask_2d.x * mask_2d.y * light, intensity);
    return rgb * vig;
}

void fragment(){
    vec3 color = texture(screen_texture, SCREEN_UV).rgb;
    COLOR = vec4(vignette(color, UV), 1.0);
}