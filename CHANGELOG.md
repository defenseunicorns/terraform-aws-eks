# Changelog

## [0.0.11](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.10...v0.0.11) (2023-10-28)


### Miscellaneous Chores

* **deps:** update all dependencies ([#65](https://github.com/defenseunicorns/terraform-aws-eks/issues/65)) ([0767870](https://github.com/defenseunicorns/terraform-aws-eks/commit/07678704a4a12267a488e975181132314c9474f4))
* **deps:** update all dependencies ([#67](https://github.com/defenseunicorns/terraform-aws-eks/issues/67)) ([b5fa6ef](https://github.com/defenseunicorns/terraform-aws-eks/commit/b5fa6efe614ca0482c629b3623a7e5178fef3347))
* **deps:** update all dependencies ([#69](https://github.com/defenseunicorns/terraform-aws-eks/issues/69)) ([83414cc](https://github.com/defenseunicorns/terraform-aws-eks/commit/83414ccf97aa31274f4a6e72d72fbb74e0a205d1))
* **deps:** update module golang.org/x/net to v0.17.0 [security] ([#78](https://github.com/defenseunicorns/terraform-aws-eks/issues/78)) ([61882cd](https://github.com/defenseunicorns/terraform-aws-eks/commit/61882cd1065739bcd4ec71f5b375f50d045486fe))
* **deps:** update module google.golang.org/grpc to v1.56.3 [security] ([#79](https://github.com/defenseunicorns/terraform-aws-eks/issues/79)) ([6b72995](https://github.com/defenseunicorns/terraform-aws-eks/commit/6b729957a7828fbe282f7abeaa6b8a44427f6a75))


### Continuous Integration

* update-configs branch from delivery-github-repo-management ([#77](https://github.com/defenseunicorns/terraform-aws-eks/issues/77)) ([6c64293](https://github.com/defenseunicorns/terraform-aws-eks/commit/6c6429300bfced887925a5d7c50ffdaea8fb338b))

## [0.0.10](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.9...v0.0.10) (2023-09-15)


### Bug Fixes

* update example for secrets csi driver and aws lb controller ([#60](https://github.com/defenseunicorns/terraform-aws-eks/issues/60)) ([a74cfbb](https://github.com/defenseunicorns/terraform-aws-eks/commit/a74cfbb3fdefe42057cbe751522e59fecbf57b7c))


### Miscellaneous Chores

* **deps:** update all dependencies ([#63](https://github.com/defenseunicorns/terraform-aws-eks/issues/63)) ([a98ebe0](https://github.com/defenseunicorns/terraform-aws-eks/commit/a98ebe0593bc0d97bf090a7f463d02a29d4d6557))
* **deps:** update all dependencies ([#64](https://github.com/defenseunicorns/terraform-aws-eks/issues/64)) ([229336d](https://github.com/defenseunicorns/terraform-aws-eks/commit/229336d2975a9c97b77545364555a234de056a74))


### Continuous Integration

* this means target, not the name of the branch ([#62](https://github.com/defenseunicorns/terraform-aws-eks/issues/62)) ([8ac4b99](https://github.com/defenseunicorns/terraform-aws-eks/commit/8ac4b995f020c81a612297c7ebde9500a8ebe63e))

## [0.0.9](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.8...v0.0.9) (2023-09-12)


### Bug Fixes

* add optional secrets csi driver and aws lb controller ([#59](https://github.com/defenseunicorns/terraform-aws-eks/issues/59)) ([5c8f07e](https://github.com/defenseunicorns/terraform-aws-eks/commit/5c8f07ed26607045503afafff9044dbb4d0991dd))


### Miscellaneous Chores

* **deps:** update all dependencies ([#52](https://github.com/defenseunicorns/terraform-aws-eks/issues/52)) ([7d6a7f9](https://github.com/defenseunicorns/terraform-aws-eks/commit/7d6a7f9d06e68f9b15a11e7d340ce9bd1f0117e3))

## [0.0.8](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.7...v0.0.8) (2023-09-06)


### Bug Fixes

* refactor away from kubectl provider and fix precommit ([#53](https://github.com/defenseunicorns/terraform-aws-eks/issues/53)) ([1f44320](https://github.com/defenseunicorns/terraform-aws-eks/commit/1f44320b73cf50d391914478aff99edb4f0bb64f))


### Miscellaneous Chores

* **deps:** update all dependencies ([#44](https://github.com/defenseunicorns/terraform-aws-eks/issues/44)) ([79bc088](https://github.com/defenseunicorns/terraform-aws-eks/commit/79bc08875be77453293ae3d5008ad73ed1d96229))

## [0.0.7](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.6...v0.0.7) (2023-08-30)


### Features

* Remove calico and simplify example ([494fc55](https://github.com/defenseunicorns/terraform-aws-eks/commit/494fc5535cf1bf3a051428b41f10b68f235ff4d1))


### Continuous Integration

* remove region to fix tests ([#47](https://github.com/defenseunicorns/terraform-aws-eks/issues/47)) ([dc9aee5](https://github.com/defenseunicorns/terraform-aws-eks/commit/dc9aee5d87a8bfdfb575450fcada4971a6c6f21a))
* update ci for app ([#49](https://github.com/defenseunicorns/terraform-aws-eks/issues/49)) ([0211373](https://github.com/defenseunicorns/terraform-aws-eks/commit/0211373c3aab9634f3971a47e1d6fb235e90cca5))

## [0.0.6](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.5...v0.0.6) (2023-08-28)


### Bug Fixes

* Add EBS role boundary. ([#42](https://github.com/defenseunicorns/terraform-aws-eks/issues/42)) ([21ce795](https://github.com/defenseunicorns/terraform-aws-eks/commit/21ce79533cbeaa15b2d74242192159e1fa92a59d))


### Miscellaneous Chores

* **ci:** add release-please.yml ([#45](https://github.com/defenseunicorns/terraform-aws-eks/issues/45)) ([5b33dbc](https://github.com/defenseunicorns/terraform-aws-eks/commit/5b33dbccfe3289e6fee8583dfa076a8aa1d8ec00))


### Continuous Integration

* Refactor workflows for consolidated pipelines ([#41](https://github.com/defenseunicorns/terraform-aws-eks/issues/41)) ([3f6ffd0](https://github.com/defenseunicorns/terraform-aws-eks/commit/3f6ffd0e3545a09273743062a89eaee7c74c1342))

## [0.0.5](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.4...v0.0.5) (2023-08-17)


### Miscellaneous Chores

* configure release please and codeowners for git repo ([#37](https://github.com/defenseunicorns/terraform-aws-eks/issues/37)) ([5f3e74e](https://github.com/defenseunicorns/terraform-aws-eks/commit/5f3e74e72ea7d76004b17f7da79e17e949e6f761))

## 0.0.4 (2023-08-17)

## What's Changed
* Migration from blueprints and decouple bastion requirements by @zack-is-cool in https://github.com/defenseunicorns/terraform-aws-eks/pull/35

## New Contributors
* @zack-is-cool made their first contribution in https://github.com/defenseunicorns/terraform-aws-eks/pull/35

**Full Changelog**: https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.3...v0.0.4

## 0.0.3 (2023-07-24)

## What's Changed
* K8s 1.27 by @ntwkninja in https://github.com/defenseunicorns/terraform-aws-eks/pull/28

## New Contributors
* @ntwkninja made their first contribution in https://github.com/defenseunicorns/terraform-aws-eks/pull/28

**Full Changelog**: https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.2...v0.0.3

## 0.0.2 (2023-07-18)

## What's Changed
* Update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/3
* Update .tool-versions by @RothAndrew in https://github.com/defenseunicorns/terraform-aws-eks/pull/7
* Update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/6
* Fix typo in workflow docker cache by @RothAndrew in https://github.com/defenseunicorns/terraform-aws-eks/pull/8
* Change Renovate config to look at github tags for Build Harness updates by @RothAndrew in https://github.com/defenseunicorns/terraform-aws-eks/pull/11
* Change Renovate to only run once per day on weekdays by @RothAndrew in https://github.com/defenseunicorns/terraform-aws-eks/pull/12
* Update renovate.json5 by @RothAndrew in https://github.com/defenseunicorns/terraform-aws-eks/pull/13
* Update CODEOWNERS by @RothAndrew in https://github.com/defenseunicorns/terraform-aws-eks/pull/14
* Update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/9
* fix: migrate to a common workflow by @wirewc in https://github.com/defenseunicorns/terraform-aws-eks/pull/15
* chore(deps): update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/18
* Feature/initial oscal component by @CloudBeard in https://github.com/defenseunicorns/terraform-aws-eks/pull/19
* chore(deps): update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/21
* Bump google.golang.org/grpc from 1.51.0 to 1.53.0 by @dependabot in https://github.com/defenseunicorns/terraform-aws-eks/pull/20
* chore(deps): update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/22
* feat: updated oscal version and release please by @CloudBeard in https://github.com/defenseunicorns/terraform-aws-eks/pull/24
* chore(deps): update all dependencies by @renovate in https://github.com/defenseunicorns/terraform-aws-eks/pull/23

## New Contributors
* @renovate made their first contribution in https://github.com/defenseunicorns/terraform-aws-eks/pull/3
* @CloudBeard made their first contribution in https://github.com/defenseunicorns/terraform-aws-eks/pull/19
* @dependabot made their first contribution in https://github.com/defenseunicorns/terraform-aws-eks/pull/20

**Full Changelog**: https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.1...v0.0.2
