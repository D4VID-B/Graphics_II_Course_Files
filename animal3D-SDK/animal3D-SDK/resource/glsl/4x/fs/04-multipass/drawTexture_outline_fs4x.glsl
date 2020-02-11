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

uniform sampler2D uTex_shadow;
uniform sampler2D uTex_dm;

uniform sampler2D screenTexture;

in vec4 coord;

out vec4 rtFragColor;


mat3 xKernal = mat3( 
    1.0, 2.0, 1.0, 
    0.0, 0.0, 0.0, 
   -1.0, -2.0, -1.0 
);
mat3 yKernal = mat3( 
    1.0, 0.0, -1.0, 
    2.0, 0.0, -2.0, 
    1.0, 0.0, -1.0 
);

float getGrayscale(vec4 color){
	return length(color) /4;
}

float getSobelValue(sampler2D theTexture, mat3 kernal, int x, int y){

	vec3 screenTexture = texture(screenTexture, coord.xy).rgb;

	
	float magX =0;
	for(int i = 0; i < 3; i++){
		for(int j = 0; j < 3; j++){

			//Which surrounding pixel to grab the color of
			int xn = x + i - 1;
			int yn = y + j - 1;

			magX += xKernal[i][j] * getGrayscale(texelFetch(theTexture, ivec2(xn, yn), 1));
		}
	}
	return magX;
}

void main()
{
	float width = textureSize(screenTexture, 0).x;
	float height = textureSize(screenTexture, 0).y;

	

	int x = int(coord.x * width);
	int y = int(coord.y * height);

	float xConvolution = getSobelValue(screenTexture, xKernal, x, y);
	float yConvolution = getSobelValue(screenTexture, yKernal, x, y);

	rtFragColor = vec4(xConvolution, 0.0, 0.0, 1.0);

} 