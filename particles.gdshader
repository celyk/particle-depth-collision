shader_type particles;


uniform float spray : hint_range(0.0,5.0) = 0.4;
uniform float bounciness : hint_range(0.0,1.0) = 0.5;
uniform float friction : hint_range(0.0,1.0) = 0.01;


uniform vec3 start_velocity;

uniform sampler2D tex;

uniform vec2 my_screen_pixel_size;

uniform mat4 my_camera;
uniform mat4 my_scuffed_projection;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}


vec2 getUV(vec3 pos,mat4 viewToClip, mat4 worldToView){
	vec4 p = viewToClip*worldToView*vec4(pos,1);
	p.xyz /= p.w;
	return p.xy*.5+.5;
}

vec3 getWorldPos(vec2 screen, float depth, mat4 clipToView, mat4 viewToWorld){
	vec3 ndc = vec3(screen, depth) * 2.0 - 1.0;
	/*vec4 view = clipToView * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;*/
	
	vec4 world = viewToWorld * clipToView * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	return world_position;
}

void vertex(){
	if(RESTART){	
		// random vector
		uint base_number = NUMBER;
		uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);

		vec3 rv = vec3(rand_from_seed(alt_seed),rand_from_seed(alt_seed),rand_from_seed(alt_seed))-.5;
		
		CUSTOM.w = 0.;
		COLOR.xyz = vec3(rv+.5)*1.2;
		TRANSFORM[3].xyz = EMISSION_TRANSFORM[3].xyz; //-rand_from_seed(alt_seed)*start_velocity*DELTA;
		VELOCITY = start_velocity+rv*spray;
	}
	else{
		// reconstruct projection matrix
		mat4 my_projection = my_scuffed_projection;
		my_projection[2][3] = -1.;
		my_projection[3][3] = 0.;
		
		// get screen space coordinates of particle
		vec2 uv = getUV(TRANSFORM[3].xyz,my_projection,inverse(my_camera));
		vec4 T = textureLod(tex,uv,0.);
		
		vec3 scene_pos = getWorldPos(uv,T.w,inverse(my_projection),my_camera);

		float scene_t = length(scene_pos - my_camera[3].xyz);
		float particle_t = length(TRANSFORM[3].xyz - my_camera[3].xyz);
		
		vec3 view = normalize(scene_pos - my_camera[3].xyz);
		
		float penetration_depth = scene_t - particle_t;
		bool colliding = penetration_depth <= 0. && penetration_depth >= -length(VELOCITY)*.1;
		
		
		// handle collision
		if(colliding){
			// reconstruct normal on scene
			vec3 e = vec3(my_screen_pixel_size,0);
			vec4 Ta = textureLod(tex,uv+e.xz,0.);
			vec4 Tb = textureLod(tex,uv+e.zy,0.);
			vec3 scene_pos_a = getWorldPos(uv+e.xz,Ta.w,inverse(my_projection),my_camera);
			vec3 scene_pos_b = getWorldPos(uv+e.zy,Tb.w,inverse(my_projection),my_camera);
			
			vec3 collision_normal = normalize( cross(normalize(scene_pos_a-scene_pos),normalize(scene_pos_b-scene_pos)) );
			
			float collision_depth = dot(collision_normal,scene_pos - TRANSFORM[3].xyz);
			
			TRANSFORM[3].xyz += collision_normal * collision_depth;
			vec3 a = collision_normal * dot(collision_normal, VELOCITY);
			VELOCITY -= a;
			VELOCITY = mix(VELOCITY, vec3(0.0), friction); //V - Vf dt
			VELOCITY -= a*bounciness;
		}
		
		// simulate
		
		CUSTOM.w += DELTA;
		
		// integrate gravity acceleration
		VELOCITY += vec3(0,-2,0)*DELTA;
		
		//TRANSFORM = mat4(vec4(1,0,0,0),vec4(0,1,0,0),vec4(0,0,1,0),TRANSFORM[3]);
		//TRANSFORM[0].xyz = TRANSFORM[0].xyz + (8.)*VELOCITY*dot(TRANSFORM[0].xyz,VELOCITY);
		//TRANSFORM[1].xyz = TRANSFORM[1].xyz + (8.)*VELOCITY*dot(TRANSFORM[1].xyz,VELOCITY);
		//TRANSFORM[2].xyz = TRANSFORM[2].xyz + (8.)*VELOCITY*dot(TRANSFORM[2].xyz,VELOCITY);
		
		COLOR.w = smoothstep(LIFETIME,LIFETIME-.5,CUSTOM.w)*.5;
		
	}
	
	vec3 view_pos = (inverse(my_camera)*vec4(TRANSFORM[3].xyz,1)).xyz;
	if(RESTART) TRANSFORM[1].xyz = view_pos;
	TRANSFORM[0].xyz = (view_pos - TRANSFORM[1].xyz)/DELTA;
	TRANSFORM[1].xyz = view_pos;
}