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

uniform vec4 [] uLightPos;
uniform vec4 [] uLightCol;

uniform vec4 ubPointLight;

uniform int uLightCt;

uniform vec4 uColor;

in vec4 csPos;

out vec4 rtFragColor;

in vec4 coord;
in vec4 viewPos;
in vec4 transformedNormal;

uniform sampler2D uImage0;

vec4 getLight(vec4 lightCol, vec4 lightPos, vec4 objectColor)
{


	vec4 lNorm = normalize(lightPos - coord);

	float iDiff = dot(normalize(transformedNormal), lNorm);

	vec4 deffuse = iDiff * lightCol;

	vec4 result = deffuse * objectColor;

	return result;


}


void main()
{
	vec4 objectColor = texture(uImage0, coord.xy);

	vec4 sumOfColors = vec4(0, 0, 0, 0);

	
	/*
    // Since non constant indexis aren't allowed for array access in GLSL this breaks everything
    for(int lightNum = 0; lightNum < uLightCt; lightNum++)
		getLight(uLightCol[lightNum], uLightPos[lightNum], objectColor);   */

	if(uLightCt > 0){
		sumOfColors += getLight(uLightCol[0], uLightPos[0], objectColor);
	}
	if(uLightCt > 1){
		sumOfColors += getLight(uLightCol[1], uLightPos[1], objectColor);
	}	

	if(uLightCt > 2){
		sumOfColors += getLight(uLightCol[2], uLightPos[2], objectColor);
	}	

	if(uLightCt > 3){
		sumOfColors += getLight(uLightCol[3], uLightPos[3], objectColor);
	}	

	rtFragColor = sumOfColors;

}

