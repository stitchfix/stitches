## Problem

«Brief overview of the problem»

## Solution

«Brief description of how you solved the problem»

## Checklist

### Before Merging

- [ ] Bump the version in `version.rb` following [SemVer](https://semver.org) **on this branch** (if you were testing an RC, make sure you remove the RC before merging)

### After Merging

- [ ] Fetch `master` locally and run `rake release` **on `master`** to release the new version on Gemfury
- [ ] Add [release notes](https://github.com/stitchfix/messaging/releases) - **this is very important in helping other engineers understand what changed in the new version**
