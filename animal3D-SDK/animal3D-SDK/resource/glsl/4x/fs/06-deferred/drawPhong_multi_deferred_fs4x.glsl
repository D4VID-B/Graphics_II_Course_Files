/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as uniform block
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled


layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtViewPosition;
layout (location = 2) out vec4 rtViewNormal;
layout (location = 3) out vec4 rtAtlasTexcoord;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

//g-buffer textures as unifrom samplers
uniform sampler2D uImage00; //Depth
uniform sampler2D uImage01; //Position
uniform sampler2D uImage02; //Normal
uniform sampler2D uImage03; //Texcoord
uniform sampler2D uImage04; //Diffuse Textures/Maps?
uniform sampler2D uImage05; //Speculap Textures/Maps?
uniform sampler2D uImage06; //Shadow map 
uniform sampler2D uImage07; //Earth texture

uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
uniform float uLightSz[4];
uniform int uLightCt;
uniform vec4 uColor;
uniform mat4 uPB_inv;

in vec4 vTexcoord;

//vec4 viewPosition = texture(uImage01, vTexcoord.xy);



vec4 getLambert(vec4 lightDirection, vec4 normal, vec4 lightColor, float lightSize)
{
	float diff = max(dot(normal, lightDirection), 0.0);
	return diff * lightColor * lightSize/100;
}

vec4 getSpecular(vec4 lightDirection, vec4 viewPosition, vec4 normal, vec4 lightColor, vec4 lightPosition, float lightSize)
{
	vec4 viewDirection = normalize(-viewPosition);
	vec4 reflectionDirection = reflect(-lightDirection, normal);
	float spec = pow(max(dot(viewDirection, reflectionDirection), 0), 4);
	vec4 specular = spec * lightColor * lightSize/100;
	return specular;
}


void main()
{

	vec4 cooridnate = texture(uImage03, vTexcoord.xy);
	vec4 diffuse_map = texture(uImage04, cooridnate.xy);
	vec4 specular_map = texture(uImage05, cooridnate.xy);
	vec4 ambient = uColor * 0.01;
	vec4 lightDirection;
	vec4 attenuation;
	vec4 specular;
	vec4 diffuse;


	float depth = texture(uImage00, vTexcoord.xy).x;
	vec4 rawPosition = vec4(vTexcoord.xy, depth, 1.0);
	vec4 reverseProjPosition = uPB_inv * rawPosition; //Do reverse projection
	reverseProjPosition = reverseProjPosition / reverseProjPosition.a; //Perspective Devide

	vec4 normal = texture(uImage02, vTexcoord.xy);
	vec4 remappedNormal = (normal) * 2 - 1;

	for(int i = 0; i < uLightCt; i++)
	{
		lightDirection = normalize(uLightPos[i] - reverseProjPosition);
		attenuation += getLambert(lightDirection, remappedNormal, uLightCol[i], uLightSz[i]);
		specular += getSpecular(lightDirection, reverseProjPosition, remappedNormal, uLightCol[i], uLightPos[i], uLightSz[i]);
	}


	rtFragColor =  vec4((specular * specular_map + attenuation * diffuse_map + ambient).xyz, diffuse_map.a);

	rtDiffuseMapSample = vec4(diffuse_map.xyz,1.0);
	rtSpecularMapSample = vec4(specular_map.xyz, 1.0);
	rtDiffuseLightTotal = vec4(attenuation.xyz, 1.0);
	rtSpecularLightTotal = vec4(specular.xyz, 1.0);

	rtViewPosition = reverseProjPosition;
	rtViewNormal = vec4(normalize(normal).xyz , 1.0);
	rtAtlasTexcoord = vec4(cooridnate.xyz, 1.0);
}
