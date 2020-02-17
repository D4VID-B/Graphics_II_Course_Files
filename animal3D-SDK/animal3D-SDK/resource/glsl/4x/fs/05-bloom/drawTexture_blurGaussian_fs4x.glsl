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
uniform float[2] uBlurAxis; //I can't figure out how to pass in vec2
uniform vec2 uSize;

uniform float[5] uGaussX;


layout (location = 0) out vec4 rtFragColor;
in vec4 passTexcoord;



//vec4 populateKernel(float[5] uGaussX, sampler2D image) //Using https://www.taylorpetrick.com/blog/post/convolution-part4 and outline shader as reference
vec3 applyGauss(float[5] gauss, vec2 axis, sampler2D image, vec2 coord)
{
	vec2 size = 1.0 / textureSize(uImage00, 0);
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
//	float offset = 0;

	color += texture(image, (coord -  size*axis * 2)) * gauss[0];
	color += texture(image, (coord -  size * axis)) * gauss[1];
	color += texture(image, (coord)) * gauss[2];
	color += texture(image, (coord +  size * axis)) * gauss[3];
	color += texture(image, (coord +  size * axis * 2)) * gauss[4];

	return color.xyz;

//while not very efficient becuase of the if() statement, the only other alternative would be to use a secod, virtually identical shader, which I am not sure we can 
//if(uAxis.x == 0)
//{
// offset = 1 / uSize.y;
//
// 	color += texture2D(image, vec2( passTexcoord.x, passTexcoord.y - offset * 2)) * uGaussX[0];
//	color += texture2D(image, vec2( passTexcoord.x, passTexcoord.y - offset)) * uGaussX[1];
//	color += texture2D(image, vec2( passTexcoord.x, passTexcoord.y)) * uGaussX[2];
//	color += texture2D(image, vec2( passTexcoord.x, passTexcoord.y + offset)) * uGaussX[3];
//	color += texture2D(image, vec2( passTexcoord.x, passTexcoord.y + offset * 2)) * uGaussX[4];
//
//}
//else if(uAxis.y == 0)
//{
// offset = 1 / uSize.x;
//
// 	color += texture2D(image, vec2( passTexcoord.x - offset * 2, passTexcoord.y)) * uGaussX[0];
//	color += texture2D(image, vec2( passTexcoord.x - offset, passTexcoord.y)) * uGaussX[1];
//	color += texture2D(image, vec2( passTexcoord.x, passTexcoord.y)) * uGaussX[2];
//	color += texture2D(image, vec2( passTexcoord.x + offset, passTexcoord.y)) * uGaussX[3];
//	color += texture2D(image, vec2( passTexcoord.x + offset * 2, passTexcoord.y)) * uGaussX[4];
//
//}
//else
//{
//color = vec4(1.0);
//}
//
//
//	return color;
}



void main()
{
	//Using uGaussX causes everything to break even though it does contain the correct values (I checked by outputting as colors)
	float gaussTest[5] = float[5](.0625, .25, .375, .25, .0625);

	//Once the uniform starts getting passed in use that instead. I have no idea why I can't use unif
	

	vec2 testAxis = vec2(1.0, 0.0);
	vec2 blurAxis = vec2(uBlurAxis[0], uBlurAxis[1]);
	
	//rtFragColor = vec4(applyGauss(gaussTest, testAxis , uImage00, passTexcoord.xy), 1.0);
	rtFragColor = vec4(uBlurAxis[1], uBlurAxis[0], 0, 1);
	//vec2 size = 1.0 / textureSize(uImage00, 0);	

	//vec4 blur = populateKernel(uGaussX, uImage00);
	
	//blur.a = 1.0;
	
	
	//rtFragColor = texture(uImage00, blur.xy);
}
