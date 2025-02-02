#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHTS > 0
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHTS ];
		uniform sampler2D directionalExShadowMap[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalExShadowCoord[ NUM_DIR_LIGHTS ];
		uniform sampler2D directionalHeShadowMap[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalHeShadowCoord[ NUM_DIR_LIGHTS ];
	#endif

	#if NUM_SPOT_LIGHTS > 0
		uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHTS ];
		varying vec4 vSpotShadowCoord[ NUM_SPOT_LIGHTS ];

	#endif

	#if NUM_POINT_LIGHTS > 0
		uniform sampler2D pointShadowMap[ NUM_POINT_LIGHTS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHTS ];

	#endif

	float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {

		return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );

	}

	float texture2DShadowLerp( sampler2D depths, vec2 size, vec2 uv, float compare ) {

		const vec2 offset = vec2( 0.0, 1.0 );

		vec2 texelSize = vec2( 1.0 ) / size;
		vec2 centroidUV = floor( uv * size + 0.5 ) / size;

		float lb = texture2DCompare( depths, centroidUV + texelSize * offset.xx, compare );
		float lt = texture2DCompare( depths, centroidUV + texelSize * offset.xy, compare );
		float rb = texture2DCompare( depths, centroidUV + texelSize * offset.yx, compare );
		float rt = texture2DCompare( depths, centroidUV + texelSize * offset.yy, compare );
		vec2 f = fract( uv * size + 0.5 );

		float a = mix( lb, lt, f.y );
		float b = mix( rb, rt, f.y );
		float c = mix( a, b, f.x );

		return c;
	}

	float getShadowSample( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
	#if defined( SHADOWMAP_TYPE_PCF )

		vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
		float dx0 = - texelSize.x * shadowRadius;
		float dy0 = - texelSize.y * shadowRadius;
		float dx1 = + texelSize.x * shadowRadius;
		float dy1 = + texelSize.y * shadowRadius;

		return (
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
			texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
		) * ( 1.0 / 9.0 );

	#elif defined( SHADOWMAP_TYPE_PCF_SOFT )

		vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
		float dx0 = - texelSize.x * shadowRadius;
		float dy0 = - texelSize.y * shadowRadius;
		float dx1 = + texelSize.x * shadowRadius;
		float dy1 = + texelSize.y * shadowRadius;

		return (
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy, shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
			texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
		) * ( 1.0 / 9.0 );

	#else // no percentage-closer filtering:

		return texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );

	#endif
	}

	// float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

	// 	shadowCoord.xyz /= shadowCoord.w;
	// 	shadowCoord.z += shadowBias;

	// 	if(shadowCoord.z <= 1.0) {
	// 		float x = (shadowCoord.x - 0.5) * 2.0;
	// 		float y = (shadowCoord.y - 0.5) * 2.0;
	// 		float circle =  x * x + y * y;
	// 		if ( circle < 1.0 ) {
	// 			float lerp = clamp ((1.0 - circle) * 2.5, 0.0, 1.0); // this is a lerp but in distance squared space

	// 			if( lerp < 1.0 ) { // optional conditional, faster with or without?
	// 				// easy in easy out feather
	// 				lerp = 0.5 - 0.5 * cos(lerp * 3.14159265359);
	// 			}

	// 			float a = getShadowSample(shadowMap, shadowMapSize, shadowBias, shadowRadius, shadowCoord);

	// 			return (a * lerp + (1.0 - lerp));
	// 		}
	// 	}

	// 	return 1.0;

	// }

	float sdRoundBox( vec2 p, vec2 b, float r )
	{
		vec2 q = abs(p) - b + r;
		return length(max(q,0.0)) + min(max(q.x,q.y),0.0) - r;
	}

	float circleDist( vec2 p )
	{
		float x = (p.x - 0.5) * 2.0;
		float y = (p.y - 0.5) * 2.0;
		return(x * x + y * y); // dodging square root 1*1 = 1
	}

	float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

		shadowCoord.xyz /= shadowCoord.w;
		shadowCoord.z += shadowBias;

		if(shadowCoord.z <= 1.0) {
			// float dist = sdRoundBox(shadowCoord.xy - vec2(0.5, 0.5), vec2(0.5, 0.5), 0.25);
			float dist = -1.0 + circleDist(shadowCoord.xy); // d^2
			if ( dist < 0.0 ) {
				float lerp = 1.0 - clamp ((1.0 + dist * 2.5), 0.0, 1.0);

				if( lerp < 1.0 ) { // optional conditional, faster with or without?
					// easy in easy out feather
					lerp = 0.5 - 0.5 * cos(lerp * 3.14159265359);
				}

				float a = getShadowSample(shadowMap, shadowMapSize, shadowBias, shadowRadius, shadowCoord);

				return (a * lerp + (1.0 - lerp));
			}
		}

		return 1.0;

	}

	float getDirShadow( sampler2D shadowMapA, vec2 shadowMapSizeA, vec4 shadowCoordA, sampler2D shadowMapB, vec2 shadowMapSizeB, vec4 shadowCoordB, float shadowBias, float shadowRadius ) {

		shadowCoordA.xyz /= shadowCoordA.w;
		shadowCoordA.z += shadowBias;
		shadowCoordB.xyz /= shadowCoordB.w;
		shadowCoordB.z += shadowBias;
		// if ( something && something ) breaks ATI OpenGL shader compiler
		// if ( all( something, something ) ) using this instead

		float circle =  circleDist(shadowCoordA.xy);

		if ( all (bvec2(circle < 1.0, shadowCoordA.z <= 1.0))  ) {
			float lerp = clamp ((1.0 - circle) * 2.5, 0.0, 1.0); // this is a lerp but in distance squared space

			if( lerp < 1.0 ) { // optional conditional, faster with or without?
				// easy in easy out feather
				lerp = 0.5 - 0.5 * cos(lerp * 3.14159265359);
			}

			float a = getShadowSample(shadowMapA, shadowMapSizeA, shadowBias, shadowRadius, shadowCoordA);

			float b = 1.0;
			if( lerp < 1.0 ) {
				if(shadowCoordB.z <= 1.0) {
					b = getShadowSample(shadowMapB, shadowMapSizeB, shadowBias, shadowRadius, shadowCoordB);
				}
			}

			return (a * lerp + b * (1.0 - lerp));

		}
		else
		{
			bvec4 inFrustumVec = bvec4 ( shadowCoordB.x >= 0.0, shadowCoordB.x <= 1.0, shadowCoordB.y >= 0.0, shadowCoordB.y <= 1.0 );
			bool inFrustum = all( inFrustumVec );

			bvec2 frustumTestVec = bvec2( inFrustum, shadowCoordB.z <= 1.0 );

			bool frustumTest = all( frustumTestVec );
			if ( frustumTest ) {
				return getShadowSample(shadowMapB, shadowMapSizeB, shadowBias, shadowRadius, shadowCoordB);
			}
		}
		return 1.0;
	}

	// cubeToUV() maps a 3D direction vector suitable for cube texture mapping to a 2D
	// vector suitable for 2D texture mapping. This code uses the following layout for the
	// 2D texture:
	//
	// xzXZ
	//  y Y
	//
	// Y - Positive y direction
	// y - Negative y direction
	// X - Positive x direction
	// x - Negative x direction
	// Z - Positive z direction
	// z - Negative z direction
	//
	// Source and test bed:
	// https://gist.github.com/tschw/da10c43c467ce8afd0c4

	vec2 cubeToUV( vec3 v, float texelSizeY ) {

		// Number of texels to avoid at the edge of each square

		vec3 absV = abs( v );

		// Intersect unit cube

		float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
		absV *= scaleToCube;

		// Apply scale to avoid seams

		// two texels less per square (one texel will do for NEAREST)
		v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );

		// Unwrap

		// space: -1 ... 1 range for each square
		//
		// #X##		dim    := ( 4 , 2 )
		//  # #		center := ( 1 , 1 )

		vec2 planar = v.xy;

		float almostATexel = 1.5 * texelSizeY;
		float almostOne = 1.0 - almostATexel;

		if ( absV.z >= almostOne ) {

			if ( v.z > 0.0 )
				planar.x = 4.0 - v.x;
		} else if ( absV.x >= almostOne ) {

			float signX = sign( v.x );
			planar.x = v.z * signX + 2.0 * signX;

		} else if ( absV.y >= almostOne ) {

			float signY = sign( v.y );
			planar.x = v.x + 2.0 * signY + 2.0;
			planar.y = v.z * signY - 2.0;

		}

		// Transform to UV space

		// scale := 0.5 / dim
		// translate := ( center + 0.5 ) / dim
		return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
	}

	float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

		vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );

		// for point lights, the uniform @vShadowCoord is re-purposed to hold
		// the distance from the light to the world-space position of the fragment.
		vec3 lightToPosition = shadowCoord.xyz;

		// bd3D = base direction 3D
		vec3 bd3D = normalize( lightToPosition );
		// dp = distance from light to fragment position
		float dp = ( length( lightToPosition ) - shadowBias ) / 1000.0;

		#if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT )

			vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;

			return (
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
			) * ( 1.0 / 9.0 );
		#else // no percentage-closer filtering

		return texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );

		#endif

	}

#endif