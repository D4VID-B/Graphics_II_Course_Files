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

flat in int vInstanceID;
in vec4 vBiasedClipCoord;

layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

//g-buffer textures as samplers
uniform sampler2D uImage01;
uniform sampler2D uImage02;
uniform sampler2D uImage03;
uniform sampler2D uImage04;
uniform sampler2D uImage05;

struct data
{
vec4 worldPos;
	vec4 viewPos;
	vec4 color;
	float radius;
	float radiusInvSq;
	float[2] pad;

};

uniform ubPointLight
{
	data lightStuff[4];

} lightData;


//uniform vec4 uLightPos[4];
//uniform vec4 uLightCol[4];
//uniform float uLightSz[4];
uniform int uLightCt;
uniform vec4 uColor;
uniform mat4 uPB_inv;

uniform sampler2D uImage00; //Depth





vec4 getLambert(vec4 lightDirection, vec4 normal, vec4 lightColor, float lightSize)
{
	float diff = max(dot(normal, lightDirection), 0.0);
	return diff * lightColor;
}

vec4 getSpecular(vec4 lightDirection, vec4 viewPosition, vec4 normal, vec4 lightColor, vec4 lightPosition, float lightSize)
{
	vec4 viewDirection = normalize(-viewPosition);
	vec4 reflectionDirection = reflect(-lightDirection, normal);
	float spec = pow(max(dot(viewDirection, reflectionDirection), 0), 4);
	vec4 specular = spec * lightColor;
	return specular;
}


void main()
{

	vec4 ambient = uColor * 0.01;
	vec4 lightDirection;
	vec4 attenuation;
	vec4 specular;
	vec4 diffuse;

	vec4 biasCoord = vBiasedClipCoord / vBiasedClipCoord.a;

	float depth = texture(uImage00, biasCoord.xy).x;
	vec4 rawPosition = vec4(biasCoord.xy, depth, 1.0);
	vec4 reverseProjPosition = uPB_inv * rawPosition; //Do reverse projection
	reverseProjPosition = reverseProjPosition / reverseProjPosition.a; //Perspective Devide

	vec4 normal = texture(uImage02, biasCoord.xy);
	vec4 remappedNormal = (normal) * 2 - 1;

	
	lightDirection = normalize(normal - reverseProjPosition);
	attenuation = getLambert(lightDirection, normal, lightData.lightStuff[vInstanceID].color, lightData.lightStuff[vInstanceID].radius);
	specular = getSpecular(lightDirection, reverseProjPosition, normal, lightData.lightStuff[vInstanceID].color, lightData.lightStuff[vInstanceID].viewPos, lightData.lightStuff[vInstanceID].radius);
	
	diffuse = attenuation;

//	rtFragColor = specular * diffuse * ambient;
//	rtDiffuseMapSample = diffuse_map;
//	rtSpecularMapSample = specular_map;
//	rtDiffuseLightTotal = diffuse;
//	rtSpecularLightTotal = specular;

	//diffuse *= 255;
	rtDiffuseLight = vec4(diffuse.xyz, 1.0);
	rtSpecularLight = vec4(specular.xyz, 1.0);

	//rtDiffuseLight += vec4(1.0, 1.0, 0.0, 1.0);
	//rtSpecularLight += vec4(1.0, 0.0, 1.0, 1.0);

	
}
