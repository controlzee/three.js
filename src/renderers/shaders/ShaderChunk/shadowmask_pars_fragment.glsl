float getShadowMask() {

	float shadow = 1.0;

	#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHTS > 0

	DirectionalLight directionalLight;

	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

		directionalLight = directionalLights[ i ];
		bool isEx = bool( directionalLight.shadowEx );

		if (isEx)
			shadow *= bool( directionalLight.shadow )
				? getDirShadow(
						directionalShadowMap[ i ],
						directionalLight.shadowMapSize,
						vDirectionalShadowCoord[ i ],
						directionalExShadowMap[ i ],
						directionalLight.shadowExMapSize,
						vDirectionalExShadowCoord[ i ],
						directionalLight.shadowBias,
						directionalLight.shadowRadius
					)
				: 1.0;
		else
			shadow *= bool( directionalLight.shadow )
				? getShadow(
						directionalShadowMap[ i ],
						directionalLight.shadowMapSize,
						directionalLight.shadowBias,
						directionalLight.shadowRadius,
						vDirectionalShadowCoord[ i ]
					)
				: 1.0;

	}

	#endif

	#if NUM_SPOT_LIGHTS > 0

	SpotLight spotLight;

	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {

		spotLight = spotLights[ i ];
		shadow *= bool( spotLight.shadow ) ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowBias, spotLight.shadowRadius, vSpotShadowCoord[ i ] ) : 1.0;

	}

	#endif

	#if NUM_POINT_LIGHTS > 0

	PointLight pointLight;

	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {

		pointLight = pointLights[ i ];
		shadow *= bool( pointLight.shadow ) ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ] ) : 1.0;

	}

	#endif

	#endif

	return shadow;

}
