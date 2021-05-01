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
	gl_Position = PVM * vec4( aVertex, 1. );
}
