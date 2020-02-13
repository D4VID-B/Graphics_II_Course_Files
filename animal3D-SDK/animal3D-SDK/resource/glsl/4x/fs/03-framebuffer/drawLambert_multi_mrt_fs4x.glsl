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
	
	drawLambert_multi_mrt_fs4x.glsl
	Draw Lambert shading model for multiple lights with MRT output.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!
//	5) set location of final color render target (location 0)
//	6) declare render targets for each attribute and shading component

uniform vec4 uLightPos [4];
uniform vec4 uLightCol [4];
uniform float uLightSz [4];
uniform float uLightSzInvSq [4];

uniform int uLightCt;

 in vec4 texCoord;
 in vec4 viewPos;
 in vec4 transformedNormal;

uniform sampler2D uImage0;
uniform sampler2D uTex_dm;

out vec4 rtFragColor;

layout (location = 0) out vec4 outColor;
layout (location = 1) out vec4 outPosition;
layout (location = 2) out vec4 outNormal;
layout (location = 3) out vec4 outTextureCoord;
layout (location = 4) out vec4 outDiffTexture;
layout (location = 6) out vec4 outDiffLighting;

vec4 n_lightRay;


float ambent = .1;

float attenConst = .001;

//Get defuse light for the given object
vec4 getLight(vec4 lightCol, vec4 lightPos, float lightSize)
{
	//This only works when you use the viewPos as the position. I have no idea why
	vec4 lightRay = lightPos - viewPos;

	//Implementing Attenuation
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	n_lightRay = normalize(lightRay);

	float diff_coef = max(dot(normalize(transformedNormal), n_lightRay), 0.0);

	//Light size seems to be in the range of 0 to 100, but it is more useful as a number between 0 and 1
	vec4 result = diff_coef * lightCol * (lightSize/100) * atten;
	
	return result;
}


void main()
{
	
	vec4 sumOfColors;	

	for(int i = 0; i < uLightCt; i++)
	{
		sumOfColors += getLight(uLightCol[i], uLightPos[i], uLightSz[i]);
	}

	vec4 objectColor = texture(uImage0, texCoord.xy);

	rtFragColor = objectColor * sumOfColors;

	outColor = vec4(rtFragColor.xyz, 1);
	outPosition = viewPos;
	outNormal = vec4(normalize(transformedNormal.xyz), 1);
	outTextureCoord = texCoord;
	outDiffTexture = texture(uTex_dm, texCoord.xy);
	outDiffLighting = vec4(sumOfColors.xyz, 1);
}

