## Problem

«Brief overview of the problem»

## Solution

«Brief description of how you solved the problem»

## Checklist

### Before Merging

- [ ] If there is an RC on this branch, revert the version change in `version.rb`

### After Merging

See the [gem release process](https://github.com/stitchfix/eng-wiki/blob/master/technical-topics/updating-gem-versions.md) for a detailed list, but the gist of it is:

- [ ] Fetch `master` locally and run the applicable `rake version:*` task **on `master`** to bump the version
- [ ] Run `rake release` **on `master`** to release the new version on Gemfury
- [ ] Add [release notes](https://github.com/stitchfix/messaging/releases) - **this is very important in helping other engineers understand what changed in the new version**
