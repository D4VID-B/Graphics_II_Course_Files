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

uniform vec4 uLightPos[];
uniform vec4 uLightCol[];

uniform int uLightCt;
uniform vec4 uColor;


out vec4 rtFragColor;

in vec4 coord;
in vec4 csPos;
in vec4 viewPos;
in vec4 transformedNormal;

uniform sampler2D uImage0;

vec4 getPointLight(vec4 lightPos, vec4 iNormal, vec4 pos)
{
vec4 normal;

vec4 dir = normalize(lightPos - pos);
	
vec4 diff = max(dot(iNormal, dir), 0.0) * uColor;

vec4 reflectDir = reflect(-dir, iNormal);

float spec = pow(max(dot(csPos, reflectDir), 0), 0.5);

normal += .5 + diff + spec;

return normal;
}


void main()
{
	
//	vec4 lNorm = getPointLight();
//
//	float iDiff = dot(normalize(transformedNormal), lNorm);
//
//	vec4 vNorm = normalize(viewPos - coord);
//
//	vec4 rNorm = reflect(-lNorm, transformedNormal);
//	
//	float iSpec = pow(max(dot(vNorm, rNorm), 0), 32);
vec4 iPhong;

//for (int i = 0; i < uLightCt; i++)
//{
//	iPhong += getPointLight(uLightPos[i], transformedNormal, coord);
//}

//iPhong += getPointLight(uLightPos[0], transformedNormal, coord);
//iPhong += getPointLight(uLightPos[1], transformedNormal, coord);	
//iPhong += getPointLight(uLightPos[2], transformedNormal, coord);
//iPhong += getPointLight(uLightPos[3], transformedNormal, coord);

	rtFragColor = iPhong;
	//rtFragColor = (iPhong) * texture(uImage0, coord.xy); 
}

