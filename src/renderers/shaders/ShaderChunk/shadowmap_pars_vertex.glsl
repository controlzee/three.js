#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHTS > 0

		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHTS ];
    uniform mat4 directionalExShadowMatrix[ NUM_DIR_LIGHTS ];
    varying vec4 vDirectionalExShadowCoord[ NUM_DIR_LIGHTS ];
		uniform mat4 directionalHeShadowMatrix[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalHeShadowCoord[ NUM_DIR_LIGHTS ];
	#endif

	#if NUM_SPOT_LIGHTS > 0

		uniform mat4 spotShadowMatrix[ NUM_SPOT_LIGHTS ];
		varying vec4 vSpotShadowCoord[ NUM_SPOT_LIGHTS ];

	#endif

	#if NUM_POINT_LIGHTS > 0

		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHTS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHTS ];

	#endif

#endif
