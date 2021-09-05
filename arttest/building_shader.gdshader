shader_type canvas_item;

uniform sampler2D sky_target;
uniform vec4 window_color: hint_color = vec4(1f,.8f,.7f,1f);
uniform float FIXED_TIME_OF_DAY;
uniform float residentialness: hint_range(0,1) = 1;
uniform float WINDOW_OFFSET: hint_range(0,1);
uniform vec4 override_tint_color: hint_color = vec4(0f);



const vec3 shadow_color = vec3(0.651,1.000,0.812);

const float GAMMA = 2.2f;

const float EPSILON = .00001;
const float TWO_PI = 6.28318530718;
const float PI = 3.1415926535;
const float HALF_PI = 1.57079632679;

const vec3 argb(vec3 color){
	return pow(color,vec3(1f/GAMMA));
}

const vec3 argbf(float r, float g, float b){
	return argb(vec3(r,g,b));
}

vec3 define_color(float time, float alt, float hpos){
	time = mod(time,1);
	float htime = 1f-2f*abs(time-0.5);
	float dawn_power = sin(TWO_PI*htime - HALF_PI)*0.5+0.5f;
	
	// skoosh dawn towards the day
	float skew = sin(htime*PI - HALF_PI);
	float skew_a = sign(skew)*pow(abs(skew),mix(0.55,1.5,alt));
	
	// the solar energy at a given point
	float solar = .5+.5*skew_a;
	solar *= abs(solar);
	
	vec2 sun_pos = vec2(time*1.6,time*8f-2.2f);
	vec2 sun_delta = sun_pos-vec2(hpos,alt);
	float sun_bloom = min(0.7f,.2f/max(0.001,1000f*dot(sun_delta,sun_delta)));
	
	// calculate the amount of dawn effect to show at a given point
	//2f*pow(dawn_power,6f-(-6f*(alt)))*solar*step(time,0.5)
	return vec3(solar);//*mt2u(cos(alt*2.5f));
}

void fragment() {
	ivec2 tex = ivec2(UV*TEXTURE_PIXEL_SIZE);
	vec4 ts = texture(TEXTURE,UV);
	if(ts.a<EPSILON){
		//discard;
	}
	float time = FIXED_TIME_OF_DAY;
	//time = UV.x;
	time+=0.5f;
	time=mod(time,1f);
		
		
	COLOR.a = ts.a+0.5f;
	
	vec2 sky_uv = SCREEN_UV;
	vec3 sky_color = argb(texture(sky_target,sky_uv).rgb);
	
	float is_window = 1f-step(ts.b,EPSILON);
	
	
	// window calc
	float nightness = .5f+.5*cos(PI+time*TWO_PI);
	float eveningness = .5f+.5*cos(PI+HALF_PI+.2+time*PI*1.9);
	nightness = sqrt(nightness);
	float light_amt = 2.2f*mix(nightness*.9, sqrt(nightness*eveningness), residentialness)-1f;
	
	//nightness, eveningness, light_amt
	if(UV.y>.5)
		COLOR.rgb = vec3(light_amt);
	else COLOR.rgb = define_color(UV.x,0.2,.5);
	
	float window_val = mod(ts.b+WINDOW_OFFSET,.8f)+.2f;
	//window_val = WINDOW_OFFSET;
	//COLOR.rgb = step(vec3(1f-UV.y),COLOR.rgb);
	vec3 window = sky_color*0.7+argb(window_color.rgb)*0.7*step(window_val,light_amt);
	vec3 surface_color = shadow_color*0.2;
	surface_color = mix(surface_color, override_tint_color.rgb, override_tint_color.a);
	//surface_color = vec3(window);
	COLOR.rgb=mix(surface_color, window, is_window);
	//COLOR.rgb = vec3(vec3(tex.rg),0f);
	//COLOR.rgb=mix(vec3(UV,1),COLOR.rgb, ts.a);
	// gamma correction	
	COLOR.rgb = pow(COLOR.rgb, vec3(GAMMA));
}