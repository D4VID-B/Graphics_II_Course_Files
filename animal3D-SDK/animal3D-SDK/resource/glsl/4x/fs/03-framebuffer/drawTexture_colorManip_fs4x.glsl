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
	
	drawTexture_colorManip_fs4x.glsl
	Draw texture sample and manipulate result.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare inbound varying for texture coordinate
//	3) sample texture using texture coordinate
//	4) modify sample in some creative way
//	5) assign modified sample to output color

//Cristal Ball Bonus

float ballRadius = .5;

uniform sampler2D screenTexture;

in vec4 coord;

uniform double uTime;

out vec4 rtFragColor;


void main()
{

	float tester = step(length(coord), ballRadius);

	//The numbers used are all totally arbratary and used to make it look cool
	float colorR = min(sin(float(uTime * 3)), .1); 
	float colorB = min(sin(float(uTime * 1)), .5);
	float colorG = min(sin(float(uTime * 2)), .6);
	vec4 pixelColor = texture2D(screenTexture, coord.xy) + vec4(colorR, colorB,colorG , 0);

	if(length(coord.xy) < ballRadius){
		rtFragColor = pixelColor;
	}
	else{
		rtFragColor = vec4(0, 0, 0, 1);
	}
	

}
