shader_type spatial;
varying vec3 world_position;

uniform float speed : hint_range(-5.0, 5.0) = 1.0;


void vertex() {
    world_position = VERTEX;
    world_position.x -= (TIME * speed);
}


void fragment(){
    ROUGHNESS = 0.0;
    ALBEDO = vec3(round(fract(world_position.x * 1.5)));
}