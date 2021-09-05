shader_type canvas_item;

uniform float bchannel;

void fragment(){
	COLOR.rg = UV;
	COLOR.b = bchannel;
}