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

in vec4 vTexcoord;

vec4 viewPosition = texture(uImage01, vTexcoord.xy);
vec4 normal = texture(uImage02, vTexcoord.xy);
vec4 cooridnate = texture(uImage03, vTexcoord.xy);


vec4 getLambert(vec4 lightDirection, vec4 lightColor, float lightSize)
{
float diff = max(dot(normal, lightDirection), 0.0);
return diff * lightColor * lightSize/100;
}

vec4 getSpecular(vec4 lightDirection, vec4 lightColor, vec4 lightPosition, float lightSize)
{
vec4 viewDirection = normalize(-viewPosition);
vec4 reflectionDirection = reflect(-lightDirection, normal);
float spec = pow(max(dot(viewDirection, reflectionDirection), 0.0), 4);
vec4 specular = spec * lightColor * lightSize/100;
return specular;
}


void main()
{
	vec4 diffuse_map = texture(uImage05, cooridnate.xy);
	vec4 specular_map = texture(uImage05, cooridnate.xy);
	vec4 ambient = uColor * 0.01;
	vec4 lightDirection;
	vec4 attenuation;
	vec4 specular;
	vec4 diffuse;

	for(int i = 0; i < uLightCt; i++)
	{
	lightDirection = normalize(uLightPos[i] - viewPosition);
	attenuation += getLambert(lightDirection, uLightCol[i], uLightSz[i]);
	specular += getSpecular(lightDirection, uLightCol[i], uLightPos[i], uLightSz[i]);
	}

	specular = specular * specular_map;
	diffuse = attenuation * diffuse_map;

	rtFragColor = specular * diffuse * ambient;
	rtDiffuseMapSample = diffuse_map;
	rtSpecularMapSample = specular_map;
	rtDiffuseLightTotal = diffuse;
	rtSpecularLightTotal = specular;
}
