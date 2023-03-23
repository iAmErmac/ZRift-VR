ivec2 scrsize = textureSize(InputTexture, 0);
float aspect  = scrsize.x/scrsize.y;

vec2 pixelate(vec2 uv)
{
	vec2 coord;
	if (pixelation >= 1)
		coord = vec2( (ceil(uv.x * 320 * pixelation * aspect) / (320 * pixelation * aspect)), ceil(uv.y * 200 * pixelation) / (200 * pixelation) );
	else
		coord = vec2( (ceil(uv.x * 160 * aspect) / (160 * aspect)), ceil(uv.y * 200) / 200 );
	return coord;
}

void main() 
{
	vec4 c;
	if (pixelation >= 0)
		c = texelFetch(InputTexture, ivec2(pixelate(TexCoord)*scrsize), 0);
	else
		c = texelFetch(InputTexture, ivec2(TexCoord.xy*scrsize), 0);	
	if (posterization == 1)
	{
		c = pow(c, vec4(postgamma, postgamma, postgamma, 1));
		c = c * postcolors;
		c = floor(c);
		c = c / postcolors;
		c = pow(c, vec4(1.0/postgamma));
	}
	FragColor = vec4(c);
}


