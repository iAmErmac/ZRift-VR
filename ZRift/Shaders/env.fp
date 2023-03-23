mat3 GetTBN();
vec3 GetBumpedNormal(mat3 tbn, vec2 texcoord);

Material ProcessMaterial()
{
    mat3 tbn = GetTBN();
    vec2 texCoord = vTexCoord.st;

    Material material;
	vec4 addEnv = texture(displacement, (normalize(transpose(tbn) * (uCameraPos.xyz - pixelpos.xyz)).xy) + (texture(normaltexture, texCoord).xy * 0.2));
	
	addEnv *= texture(envmask, texCoord);
	
    material.Base = getTexel(texCoord) + addEnv;
	
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