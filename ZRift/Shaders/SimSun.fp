//SimSun Shader by Cherno

mat3 GetTBN();
vec3 GetBumpedNormal(mat3 tbn, vec2 texcoord);

const float pi = 3.14159265359;
vec4 Process(vec4 color)
{
	vec3 lightDir = vec3(1.0,-1.0,-1.0);
	//Doom map axis: x,z,y
	//with 1.0-1.0,-1.0, the light comes from the north-west-west diagonally downwards, if north is towards the top of the (auto or editor)map

	vec2 texCoord = gl_TexCoord[0].st;
	vec3 l = lightDir;
	vec3 n = normalize(vWorldNormal.xyz);
	float angle = acos
	(
		(l.x*n.x + l.y*n.y + l.z * n.z) 
		/ 
		(
			(	
				sqrt
				(
					(l.x*l.x)+(l.y*l.y)+(l.z*l.z)
				) 
				* 
				sqrt
				(
					(n.x*n.x) + (n.y*n.y) + (n.z*n.z)
				)
			)
		)
	);
	float lightLevel = angle;
	lightLevel /= pi;
	//from here on out, you have a lightLevel between 0.0 and 1.0, depending on the angle of the surface relative to lightDir.
	//a lightLevel of 0.5 results in the pixel at it would appear with no shading from SimSun at all.
	//you can add calculations to the lightvalue if you wish to increase, decrease, or shoft the effect.
	lightLevel += 0.25;//shifts the lightLevel so it gets slightly lighter, so there are less extremely dark areas
	return getTexel(texCoord) * color * vec4(lightLevel,lightLevel,lightLevel,1.0);
}

Material ProcessMaterial()
{
    mat3 tbn = GetTBN();
	vec2 texCoord = gl_TexCoord[0].st;

    Material material;
    material.Base = getTexel(texCoord);
    material.Normal = GetBumpedNormal(tbn, texCoord);
#if defined(SPECULAR)
    material.Specular = texture(speculartexture, texCoord).rgb;
    material.Glossiness = uSpecularMaterial.x;
    material.SpecularLevel = uSpecularMaterial.y;
#endif
#if defined(PBR)
    material.Metallic = texture(metallictexture, texCoord).r;
    material.Roughness = texture(roughnesstexture, texCoord).r;
    material.AO = texture(aotexture, texCoord).r;
#endif
#if defined(BRIGHTMAP)
    material.Bright = texture(brighttexture, texCoord);
#endif
    return material;
}

// Tangent/bitangent/normal space to world space transform matrix
mat3 GetTBN()
{
    vec3 n = normalize(vWorldNormal.xyz);
    vec3 p = pixelpos.xyz;
    vec2 uv = vTexCoord.st;

    // get edge vectors of the pixel triangle
    vec3 dp1 = dFdx(p);
    vec3 dp2 = dFdy(p);
    vec2 duv1 = dFdx(uv);
    vec2 duv2 = dFdy(uv);

    // solve the linear system
    vec3 dp2perp = cross(n, dp2); // cross(dp2, n);
    vec3 dp1perp = cross(dp1, n); // cross(n, dp1);
    vec3 t = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 b = dp2perp * duv1.y + dp1perp * duv2.y;

    // construct a scale-invariant frame
    float invmax = inversesqrt(max(dot(t,t), dot(b,b)));
    return mat3(t * invmax, b * invmax, n);
}

vec3 GetBumpedNormal(mat3 tbn, vec2 texcoord)
{
#if defined(NORMALMAP)
    vec3 map = texture(normaltexture, texcoord).xyz;
    map = map * 255./127. - 128./127.; // Math so "odd" because 0.5 cannot be precisely described in an unsigned format
    map.xy *= vec2(0.5, -0.5); // Make normal map less strong and flip Y
    return normalize(tbn * map);
#else
    return normalize(vWorldNormal.xyz);
#endif
}