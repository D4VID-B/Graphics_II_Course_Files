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
	
	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!

uniform vec4 uLightPos [4];
uniform vec4 uLightCol [4];

uniform int uLightCt;

in vec4 texCoord;
in vec4 surfaceCoord;
in vec4 transformedNormal;

uniform sampler2D uImage0;

out vec4 rtFragColor;

vec4 n_lightRay;

vec4 getLight(vec4 lightCol, vec4 lightPos)
{
	vec4 lightRay = lightPos - surfaceCoord;

	n_lightRay = normalize(lightRay);

	float diff_coef = dot(normalize(transformedNormal), n_lightRay);

	vec4 result = diff_coef * lightCol;
	
	return result;
}

float getSpecular(vec4 lightPos, float exponenet)
{

//TODO:: change uLightPos[] to the camera position!!!
vec4 viewerDir = uLightPos[0] - surfaceCoord;
vec4 viewerDir_normalized = normalize(viewerDir);

vec4 reflectDir = 2 * (dot(normalize(transformedNormal), n_lightRay)) * normalize(transformedNormal) - n_lightRay;

float specularCoeff = pow(dot(viewerDir_normalized, reflectDir), exponenet);

return specularCoeff;
}

void main()
{
	
	vec4 sumOfColors;	

	for(int i = 0; i < uLightCt; i++)
	{
		sumOfColors += getLight(uLightCol[i], uLightPos[i]) + getSpecular(uLightPos[i], 1);
	}

	sumOfColors += .5;

	vec4 objectColor = texture(uImage0, texCoord.xy);

	rtFragColor = objectColor * sumOfColors;

}