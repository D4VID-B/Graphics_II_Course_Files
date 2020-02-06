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
	
	drawPhong_multi_shadow_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output and 
		shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy existing Phong shader
//	1) receive shadow coordinate
//	2) perform perspective divide
//	3) declare shadow map texture
//	4) perform shadow test

in vec4 shadowCoord;
uniform sampler2D uTex_shadow;
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

uniform vec4 uLightPos [4];
uniform vec4 uLightCol [4];
uniform float uLightSz [4];
uniform float uLightSzInvSq [4];

uniform int uLightCt;

in vec4 texCoord;
in vec4 viewPos;
in vec4 transformedNormal;

uniform sampler2D uImage0;

out vec4 rtFragColor;

vec4 n_lightRay;


float ambent = .1;
float specularStrength = .4;

float attenConst = .001;

//Get defuse light for the given object
vec4 getLight(vec4 lightCol, vec4 lightPos, float lightSize)
{
	//This only works when you use the viewPos as the position. I have no idea why
	vec4 lightRay = lightPos - viewPos;

	n_lightRay = normalize(lightRay);

	//Implementing Attenuaton
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	float diff_coef = max(dot(normalize(transformedNormal), n_lightRay), 0.0);

	//Light size seems to be in the range of 0 to 100, but it is more useful as a number between 0 and 1
	vec4 result = diff_coef * lightCol * (lightSize/100) * atten;
	
	return result;
}

//Get the specular coeffent
float getSpecular(vec4 lightPos, float exponenet)
{

	vec4 viewerDir_normalized = normalize(viewPos);

	//Leaving this here to show how the math works
	//vec4 reflectDir = 2 * (dot(normalize(transformedNormal), n_lightRay)) * normalize(transformedNormal) - n_lightRay;

	vec4 reflectDir = reflect(-n_lightRay, normalize(transformedNormal));

	//Implementing Attenuaton
	vec4 lightRay = lightPos - viewPos;
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);


	return pow(max(dot(viewerDir_normalized, reflectDir), 0.0), exponenet) * atten;
}

void main()
{
	
	vec4 allDefuse;	
	vec4 allSpecular;	

	
	//Get the sum of defuse and specular for all lights
	for(int i = 0; i < uLightCt; i++)
	{
		allDefuse += getLight(uLightCol[i], uLightPos[i], uLightSz[i]);
		allSpecular += getSpecular(uLightPos[i], uLightSz[i]);
	}

	//Performing perspective divide
	vec4 temp = shadowCoord / shadowCoord.w;
	float shadowOut = texture2D(uTex_shadow, temp.xy).r;
	bool isShadow = ( temp.z > shadowOut);

	//Get object texture color
	vec4 objectColor = texture(uTex_dm, texCoord.xy);

	vec3 outputColor = ((ambent + allDefuse + specularStrength * allSpecular) * objectColor).xyz;

	vec3 color = vec3(1.0, 0, 0);
	if( temp.z > shadowOut)
	{
		color = vec3(0, 1.0, 0);
		objectColor.rgb = vec3(1.0, 0, 0);
		
	}

	//Add together all types of light for phong 
	rtFragColor = vec4(((ambent + allDefuse + specularStrength * allSpecular) * objectColor).xyz, 1.0);


}