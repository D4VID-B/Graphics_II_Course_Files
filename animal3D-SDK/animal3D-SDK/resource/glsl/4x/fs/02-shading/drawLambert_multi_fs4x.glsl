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
	
	drawLambert_multi_fs4x.glsl
	Draw Lambert shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

uniform vec4 uLightPos [];
uniform vec4 uLightCol [];

uniform int uLightCt;

in vec4 csPos;
in vec4 coord;
in vec4 viewPos;
in vec4 transformedNormal;

uniform sampler2D uImage0;

out vec4 rtFragColor;

vec4 getLight(vec4 lightCol, vec4 lightPos) //vec4 objectColor
{
	vec4 lightRay = lightPos - coord;
	//vec4 lNorm = lightPos - coord;

	vec4 n_lightRay = normalize(lightRay);

	float diff_coef = dot(normalize(transformedNormal), n_lightRay);
	//float iDiff = dot(transformedNormal, lNorm);

	vec4 result = diff_coef * lightCol;
	//vec4 result = deffuse * objectColor;

	return result;
}


void main()
{
	
	vec4 sumOfColors;	

		sumOfColors += getLight(uLightCol[0], uLightPos[0]);
		sumOfColors += getLight(uLightCol[1], uLightPos[1]);
		sumOfColors += getLight(uLightCol[2], uLightPos[2]);
		sumOfColors += getLight(uLightCol[3], uLightPos[3]);

	vec4 objectColor = texture(uImage0, coord.xy);

	rtFragColor = objectColor * sumOfColors;
	//rtFragColor =  vec4(1.0, 1.0, 1.0, 1.0);
	rtFragColor = getLight(uLightCol[0], uLightPos[0]);

}

