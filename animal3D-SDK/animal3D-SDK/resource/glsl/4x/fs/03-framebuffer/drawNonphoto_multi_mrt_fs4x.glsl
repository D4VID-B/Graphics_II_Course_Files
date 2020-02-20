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
	
	drawNonphoto_multi_mrt_fs4x.glsl
	Draw nonphotorealistic shading model for multiple lights with MRT output.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement nonphotorealistic shading model
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

out vec4 rtFragColor;

vec4 n_lightRay;
float attenConst = .001;


float ambent = .3;

//Get defuse light for the given object
vec4 getLight(vec4 lightCol, vec4 lightPos, float lightSize)
{
	//This only works when you use the viewPos as the position. I have no idea why
	vec4 lightRay = lightPos - viewPos;

	n_lightRay = normalize(lightRay);

	float diff_coef = max(dot(normalize(transformedNormal), n_lightRay), 0.0);

	//Implementing Attenuaton
	float dist = length(lightRay);

	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	diff_coef = diff_coef * (lightSize/100) * atten;

	if(diff_coef < .3){
		diff_coef = 0;
	}

	else if(diff_coef < .4){
		diff_coef = .1;
	}

	else if(diff_coef < .5){
		diff_coef = .5;
	}

	else if(diff_coef < .7){
		diff_coef = .6;
	}



	//Light size seems to be in the range of 0 to 100, but it is more useful as a number between 0 and 1
	vec4 result = diff_coef * lightCol;
	
	return result;
}

//Get the specular coeffent
float getSpecular(vec4 lightPos, float exponenet)
{

	vec4 viewerDir_normalized = normalize(viewPos);

	

	//Implementing Attenuaton
	vec4 lightRay = lightPos - viewPos;
	float dist = length(lightRay);
	float atten = max((1 / (1 + attenConst*pow(dist, 2))), .4);

	//Leaving this here to show how the math works
	//vec4 reflectDir = 2 * (dot(normalize(transformedNormal), n_lightRay)) * normalize(transformedNormal) - n_lightRay;
	vec4 reflectDir = reflect(-n_lightRay, normalize(transformedNormal));

	return pow(max(dot(viewerDir_normalized, reflectDir), 0.0), exponenet) * atten;
}

void main()
{
	
	vec4 allDefuse;	
	float allSpecular;	

	//Get object texture color
	vec4 objectColor = texture(uImage0, texCoord.xy);
	
	//Get the sum of defuse and specular for all lights
	for(int i = 0; i < uLightCt; i++)
	{
		allDefuse += getLight(uLightCol[i], uLightPos[i], uLightSz[i]);
		allSpecular += getSpecular(uLightPos[i], uLightSz[i]*.5);
	}

	float normalizedLightMagnatude = length(allDefuse)  / length(objectColor);

	
	if(allSpecular < .5){
		allSpecular = 0;
	}
	else{
		allSpecular = .9;
	}

	

	
	//Add together all types of light for phong 
	rtFragColor = (ambent + allDefuse +  allSpecular) * objectColor;

}
