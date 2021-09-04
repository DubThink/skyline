shader_type canvas_item;

uniform sampler2D NOISE_PATTERN;
uniform sampler2D BLUE_NOISE;
uniform float FIXED_TIME_OF_DAY;
uniform float MORNING=1;

const float TWO_PI = 6.28318530718;
const float PI = 3.1415926535;
const float HALF_PI = 1.57079632679;

float mt2u(float val_neg_1_to_1){
	return val_neg_1_to_1*0.5f + 0.5f;
}

uniform float GAMMA = 1f;

const vec3 argb(vec3 color){
	return pow(color,vec3(1f/GAMMA));
}

const vec3 argbf(float r, float g, float b){
	return argb(vec3(r,g,b));
}

const vec3 C_AZIMUTH_NIGHT = vec3(0.02,0.02,0.1);
const vec3 C_AZIMUTH_DAY = vec3(0.4,0.5,0.9);
const vec3 C_AZIMUTH_DAWN = vec3(0.502,0.073,0.600);

const vec3 C_HORIZON_NIGHT = vec3(0.15,0.17,0.25);
const vec3 C_HORIZON_DAY = vec3(0.15,0.3,.55);
const vec3 C_HORIZON_DAWN = vec3(0.969,0.408,0.184);

const vec3 C_SUN_DAY = vec3(1,.3,0);
const vec3 C_SUN_DAWN = vec3(5,.01,0);

vec3 define_color(float time, float alt, float hpos){
	time = mod(time,1);
	float htime = 1f-2f*abs(time-0.5);
	float dawn_power = sin(TWO_PI*htime - HALF_PI)*0.5+0.5f;
	
	// skoosh dawn towards the day
	float skew = sin(htime*PI - HALF_PI);
	float skew_a = sign(skew)*pow(abs(skew),mix(0.55,1.5,alt));
	
	// the solar energy at a given point
	float solar = mt2u(skew_a);
	solar *= abs(solar);
	
	vec2 sun_pos = vec2(time*1.6,time*8f-2.2f);
	vec2 sun_delta = sun_pos-vec2(hpos,alt);
	float sun_bloom = min(0.7f,.2f/max(0.001,1000f*dot(sun_delta,sun_delta)));
	
	// calculate the amount of dawn effect to show at a given point
	float final_dawn = 2f*pow(dawn_power,6f-(-6f*(alt)))*solar*step(time,0.5);//*mt2u(cos(alt*2.5f));
	
	// calculate a value that spikes hard during dawn for the colored sun
	float final_dawn_h = dawn_power;//2f*pow(dawn_power,6f-(-6f*(alt)))*solar*step(time,0.5);
	final_dawn_h*=final_dawn_h;
	final_dawn_h*=final_dawn_h;
	final_dawn_h*=final_dawn_h;

	// bloom more at dawn
	sun_bloom = mix(sun_bloom,sqrt(sun_bloom),final_dawn_h);//smoothstep(sqrt(sun_bloom),sun_bloom,htime);	
		
	
	//return vec3(dawn_power,pow(dawn_power,6)*final_dawn,final_dawn);
	vec3 azimuth = mix(mix(argb(C_AZIMUTH_NIGHT),argb(C_AZIMUTH_DAY),pow(solar,0.6)),argb(C_AZIMUTH_DAWN)*.7f,final_dawn)*0.5;
	vec3 horizon = mix(mix(argb(C_HORIZON_NIGHT),argb(C_HORIZON_DAY),solar),argb(C_HORIZON_DAWN)*1.3f,final_dawn)*0.5;
	//return vec3(final_dawn_h);
	return mix(mix(horizon, azimuth, alt),argb(mix(C_SUN_DAY,C_SUN_DAWN,final_dawn_h)),sun_bloom);
}


void fragment(){
	const float SKY_HEMISPHERE_PERCENT = .75f;
	float time_of_day = SCREEN_UV.x;
	time_of_day = TIME*0.01;
	time_of_day = FIXED_TIME_OF_DAY;
	float altitude = sin(HALF_PI*SCREEN_UV.y*SKY_HEMISPHERE_PERCENT)-0.4;
	float altitude2 = sin(SCREEN_UV.y);
	
	//mix(altitude,altitude2,step(time_of_day, .5))
	float ASPECT = SKY_HEMISPHERE_PERCENT*SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x;	
	// adjust horizontal coords to the same scale as the altitude coord
	float horiz = (SCREEN_UV.x-0.5)*ASPECT + 0.5;
	// here in case we want warbling
	vec2 jitter = vec2(0);//texture(NOISE_PATTERN, UV).rg * SCREEN_PIXEL_SIZE.y*1f;
	vec3 sky_color = define_color(time_of_day*MORNING,altitude+jitter.x,jitter.y+mix(horiz,1f-horiz,mt2u(-MORNING)));
	COLOR.rgb = sky_color;
	
	// dithering
	vec2 bn_uv = UV*10f;
	vec3 bn = texture(BLUE_NOISE,mod(bn_uv,1)).rgb;
	bn = bn*2f-1f;
	bn = sign(bn)*(1f - sqrt(1f-abs(bn)));
	// gamma correction	
	COLOR.rgb = pow(COLOR.rgb*2f + bn/127f, vec3(GAMMA));
}




