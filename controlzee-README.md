# ControlZee THREE.js fork README

This is our fork of THREE.js that we use, which has the following changes from r78:

## Changes

- Added a GL points draw mode
- Added an optional `offset` parameter to those `fromArray` methods that didn't have it
- THREE.Raycaster ignores objects with `ignoreRaycasts: true`
- Don't blow up in a couple places if bones are null/undefined
- Shader and renderer changes related to directional lights and shadow maps
- Renderer changes so objects can have a configurable near/far render cutoff
- Objects can specify an 'override material'

## Fork Rules

When making changes to this repo, please respect the following rules so that it's easier to pull in upstream changes to THREE.js, which will help us be able to stay up-to-date:

- Your changes should match the apparent code style of the code around you (ie. what THREE does), rather than using your personal preferences. In practice, this means things like whitespace inside parens, empty lines inside curly-brace bodies, etc.
- Make your diffs as small as possible; review diffs before committing and **remove any unnecessary whitespace changes**, even if they "fix" a whitespace mistake that was present in THREE. This will ensure that there will be as few merge conflicts as possible when it comes time to pull in upstream.
- Don't use format-on-save or etc; instead, be intentional about formatting and whitespace changes in order to minimize the number of diff lines in your commits.
- Don't refactor code that isn't "ours"; this will create merge conflicts when we try to pull in upstream.
