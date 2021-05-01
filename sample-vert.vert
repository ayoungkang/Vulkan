#version 400
#extension GL_ARB_separate_shader_objects  : enable
#extension GL_ARB_shading_language_420pack : enable

// non-opaque must be in a uniform block:
layout( std140, set = 0, binding = 0 ) uniform matBuf
{
        mat4 uModelMatrix;
        mat4 uViewMatrix;
        mat4 uProjectionMatrix;
	mat4 uNormalMatrix;
} Matrices;

layout( std140, set = 1, binding = 0 ) uniform lightBuf
{
	float uKa;
	float uKd;
	float uKs;
	float uShininess;
	vec4  uLightPos;
	vec4  uLightSpecularColor;
	vec4  uEyePos;
} Light;


layout( std140, set = 2, binding = 0 ) uniform miscBuf
{
	float uTime;
	int   uMode;
	int   uLighting;
	float	  uTime2;
} Misc;


layout( location = 0 ) in vec3 aVertex;
layout( location = 1 ) in vec3 aNormal;
layout( location = 2 ) in vec3 aColor;
layout( location = 3 ) in vec2 aTexCoord;


layout ( location = 0 ) out vec3 vColor;
layout ( location = 1 ) out vec2 vTexCoord;
layout ( location = 2 ) out vec3 vN;
layout ( location = 3 ) out vec3 vL;
layout ( location = 4 ) out vec3 vE;


void
main( ) 
{	

	const int NUMINSTANCES = 3;
	const float DELTA = 4.0;

	float xdelta = 0.;
	float ydelta = 0.;
	if (gl_InstanceIndex == 0)
	{
		xdelta = 0.;
	}
	else if (gl_InstanceIndex == 1)
	{
		xdelta = DELTA * (1. + float(gl_InstanceIndex / 3));
	}
	else
	{
		xdelta = DELTA * (1. + float(gl_InstanceIndex / 3)) * -1.;
	}
	

	float w = 0.5 * sin(2 * Misc.uTime);


	// rotate about X
	mat3 rotateX = mat3(1, 0, 0,
						0,	cos(w), -sin(w), 
						0, sin(w), cos(w));

	// rotate about Y
	mat3 rotateY = mat3(cos(w), 0, sin(w),
						0,		1, 0, 
						-sin(w), 0, cos(w));

	// rotate about Z
	mat3 rotateZ = mat3(cos(w),	sin(w), 0, 
						-sin(w), cos(w), 0, 
						0,		0,    1);

	mat4  P = Matrices.uProjectionMatrix;
	mat4  M = Matrices.uModelMatrix;
	mat4  V = Matrices.uViewMatrix;
	mat4 VM = V * M;
	mat4 PVM = P * VM;

	vColor    = aColor;
	vTexCoord = aTexCoord;

	vN = normalize( mat3( Matrices.uNormalMatrix ) * aNormal );
	                                                        // surface normal vector

	vec4 ECposition = M * vec4( aVertex, 1. );
	vec4 lightPos = vec4( Light.uLightPos.xyz, 1. );        // light source in fixed location
	                                                        // because not transformed
	vL = normalize( lightPos.xyz  -  ECposition.xyz );      // vector from the point
	                                                        // to the light

	vec4 eyePos = Light.uEyePos;
	vE = normalize( eyePos.xyz -  ECposition.xyz );          // vector from the point
	                                                         // to the eye
	
	//gl_Position = PVM * vec4( aVertex.xyz * rotateZ * rotateY, 1. );
	vec4 vertex = vec4(0., 0., 0., 0.);
	if (gl_InstanceIndex == 0)
	{
		vertex = vec4(aVertex.xyz * rotateY + vec3(xdelta, ydelta, 0.), 1.);
	}
	else if (gl_InstanceIndex == 1)
	{
		vertex = vec4(aVertex.xyz * rotateZ + vec3(xdelta, ydelta, 0.), 1.);
	}
	else if (gl_InstanceIndex == 2)
	{
		vertex = vec4(aVertex.xyz * rotateX + vec3(xdelta, ydelta, 0.), 1.);
	}

	gl_Position = PVM * vertex;
}
