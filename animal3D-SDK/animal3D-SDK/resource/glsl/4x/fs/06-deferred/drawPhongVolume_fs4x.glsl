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
	
	drawPhongVolume_fs4x.glsl
	Draw Phong lighting components to render targets (diffuse & specular).
*/

#version 410

#define MAX_LIGHTS 1024

// ****TO-DO: 
//	0) copy deferred Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare lighting data as uniform block
//	3) calculate lighting components (diffuse and specular) for the current 
//		light only, output results (they will be blended with previous lights)
//			-> use reverse perspective divide for position using scene depth
//			-> use expanded normal once sampled from normal g-buffer
//			-> do not use texture coordinate g-buffer

in vec4 vBiasedClipCoord;
flat in int vInstanceID;

layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

//g-buffer textures as samplers
uniform sampler2D uImage01;
uniform sampler2D uImage02;
uniform sampler2D uImage03;
uniform sampler2D uImage04;
uniform sampler2D uImage05;

uniform ubPointLight
{
	vec4 worldPos;
	vec4 viewPos;
	vec4 color;
	float radius;
	float radiusInvSq;
	float[2] pad;

} lightData;


//uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
uniform float uLightSz[4];
uniform int uLightCt;
uniform vec4 uColor;

in vec4 vTexcoord;

vec4 viewPosition = texture(uImage01, vTexcoord.xy);
vec4 normal = texture(uImage02, vTexcoord.xy);
vec4 coordinate = texture(uImage03, vTexcoord.xy);

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
	vec4 diffuse_map = texture(uImage04, coordinate.xy);
	vec4 specular_map = texture(uImage05, coordinate.xy);
	vec4 ambient = uColor * 0.01;
	vec4 lightDirection;
	vec4 attenuation;
	vec4 specular;
	vec4 diffuse;

	
	lightDirection = normalize(normal - viewPosition);
	attenuation += getLambert(lightDirection, lightData.viewPos, lightData.radius);
	specular += getSpecular(lightDirection, lightData.color, lightData.viewPos, lightData.radius);
	

	specular = specular * specular_map;
	diffuse = attenuation * diffuse_map;

//	rtFragColor = specular * diffuse * ambient;
//	rtDiffuseMapSample = diffuse_map;
//	rtSpecularMapSample = specular_map;
//	rtDiffuseLightTotal = diffuse;
//	rtSpecularLightTotal = specular;

	rtDiffuseLight = diffuse;
	rtSpecularLight = specular;
}
