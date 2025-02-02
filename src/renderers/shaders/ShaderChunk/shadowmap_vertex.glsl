#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHTS > 0

	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * worldPosition;
		vDirectionalExShadowCoord[ i ] = directionalExShadowMatrix[ i ] * worldPosition;
		vDirectionalHeShadowCoord[ i ] = directionalHeShadowMatrix[ i ] * worldPosition;
	}

	#endif

	#if NUM_SPOT_LIGHTS > 0

	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		vSpotShadowCoord[ i ] = spotShadowMatrix[ i ] * worldPosition;

	}

	#endif

	#if NUM_POINT_LIGHTS > 0

	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		tvPointShadowCoord[ i ] = pointShadowMatrix[ i ] * worldPosition;

	}

	#endif

#endif