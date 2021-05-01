#version 400
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable


layout( std140, set = 1, binding = 0 ) uniform lightBuf
{
	float uKa;
	float uKd;
	float uKs;
	float uShininess;
	vec4 uLightPos;
	vec4 uLightSpecularColor;
	vec4 uEyePos;
} Light;



layout( std140, set = 2, binding = 0 ) uniform miscBuf
{
	float uTime;
	int   uMode;
	int   uLighting;
} Misc;

// opaque must be outside of a uniform block:
// also, can't specify packing
layout( set = 3, binding = 0 ) uniform sampler2D uSampler;

layout ( location = 0 ) in vec3 vColor;
layout ( location = 1 ) in vec2 vTexCoord;
layout ( location = 2 ) in vec3 vN;
layout ( location = 3 ) in vec3 vL;
layout ( location = 4 ) in vec3 vE;

layout ( location = 0 ) out vec4 fFragColor;

void
main( )
{
	vec3 rgb;
	switch( Misc.uMode )
	{
		case 0:
			rgb = vColor;
			break;

		case 1:
			rgb = texture( uSampler, vTexCoord ).rgb;
			break;

		default:
			rgb = vec3( 1., 1., 0. );
	}

	if( Misc.uLighting != 0 )
	{
		vec3 normal = normalize(vN);
		vec3 light  = normalize(vL);
		vec3 eye    = normalize(vE);

		vec3 ambient = Light.uKa * rgb;

		float d = 0.;
		float s = 0.;
		if( dot(normal,light) > 0. )
		{
		        d = dot(normal,light);

		        vec3 ref = reflect( -light, normal );
		        if( dot(eye,ref) > 0. )
		        {
		                s = pow( dot(eye,ref), Light.uShininess );
		        }
		}
		vec3 diffuse  = Light.uKd * d * rgb;
		vec3 specular = Light.uKs * s * Light.uLightSpecularColor.rgb;

		rgb = ambient + diffuse + specular;
	}

	fFragColor = vec4( rgb, 1. );
}
