our changes to THREE

- Added a GL points draw mode
- Added an optional `offset` parameter to those `fromArray` methods that didn't have it
- THREE.Raycaster ignores objects with `ignoreRaycasts: true`
- Don't blow up in a couple places if bones are null/undefined
- Shader and renderer changes related to directional lights and shadow maps
- Renderer changes so objects can have a configurable near/far render cutoff
- Objects can specify an 'override material'
