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
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement outline algorithm - see render code for uniform hints

//https://gamedev.stackexchange.com/questions/68401/how-can-i-draw-outlines-around-3d-models

uniform sampler2D uImage0;
uniform sampler2D uImage1;
uniform sampler2D uImage2;
uniform sampler2D uImage3;
uniform sampler2D uImage4;
uniform sampler2D uImage5;
uniform sampler2D uImage6;
uniform sampler2D uImage7;

in vec4 coord;

out vec4 rtFragColor;


void main()
{
	rtFragColor = texture(uImage1, coord.xy);
	texCoord = coord;
}