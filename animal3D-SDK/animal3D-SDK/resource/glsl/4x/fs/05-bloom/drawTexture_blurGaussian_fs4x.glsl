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
	
	drawTexture_blurGaussian_fs4x.glsl
	Draw texture with Gaussian blurring.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare uniforms for pixel size and sampling axis
//	2) implement Gaussian blur function using a 1D kernel (hint: Pascal's triangle)
//	3) sample texture using Gaussian blur function and output result

uniform sampler2D uImage00;
uniform vec2 uAxis;
uniform vec2 uSize;

uniform float[5] uGaussX;


layout (location = 0) out vec4 rtFragColor;
in vec4 passTexcoord;



vec4 populateKernel(float[5] uGaussX, sampler2D image, vec2 coord)
{
vec4 color;

float offset = 1 / dot(uSize, uAxis);

	color += texture2D(image, coord + vec2( offset, offset)*uAxis) * uGaussX[0];
	color += texture2D(image, coord + vec2(0.0, offset)*uAxis) * uGaussX[1];
	color += texture2D(image, coord) * uGaussX[2];
	color += texture2D(image, coord + vec2( -offset, -offset)*uAxis) * uGaussX[3];
	color += texture2D(image, coord + vec2( -offset, 0.0)*uAxis) * uGaussX[4];

	return color;
}



void main()
{
	
	rtFragColor = vec4(uGaussX[2],uGaussX[2], uGaussX[2], 1.0);
}
