# Changelog

## [0.0.18](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.17...v0.0.18) (2024-03-26)


### Features

* add new blueprints addons and refactor some efs and ebs vars to be more concise ([#130](https://github.com/defenseunicorns/terraform-aws-eks/issues/130)) ([14144dd](https://github.com/defenseunicorns/terraform-aws-eks/commit/14144ddbf5af24181f75b952556ecee81e894bb5))


### Bug Fixes

* cert_manager errors and add more timeout for AWS ELB helm chart deploy failures ([#133](https://github.com/defenseunicorns/terraform-aws-eks/issues/133)) ([82f693a](https://github.com/defenseunicorns/terraform-aws-eks/commit/82f693abc901374b996b31019b629098c8a7f470))
* don't create resources in secure test because there's no public endpoint heh ([#135](https://github.com/defenseunicorns/terraform-aws-eks/issues/135)) ([a57d846](https://github.com/defenseunicorns/terraform-aws-eks/commit/a57d8469897da1821c35cba0c6a587a1b820e6af))
* fix cert manager policy defaults for aws partitioning ([#131](https://github.com/defenseunicorns/terraform-aws-eks/issues/131)) ([dc59a3d](https://github.com/defenseunicorns/terraform-aws-eks/commit/dc59a3d6496c5ac81ec4ed92409fcb7def7ffc6e))
* input var ([#134](https://github.com/defenseunicorns/terraform-aws-eks/issues/134)) ([af4350d](https://github.com/defenseunicorns/terraform-aws-eks/commit/af4350dcbf8f841ed0180b17d5bc92987186c873))
* secure-test fix ([#136](https://github.com/defenseunicorns/terraform-aws-eks/issues/136)) ([d5265cd](https://github.com/defenseunicorns/terraform-aws-eks/commit/d5265cd1d1158107dfa580f56c353072d46c8b76))


### Miscellaneous Chores

* **deps:** update all dependencies ([#125](https://github.com/defenseunicorns/terraform-aws-eks/issues/125)) ([bc83e98](https://github.com/defenseunicorns/terraform-aws-eks/commit/bc83e9847b8fd49884fc2152d219c45d323c5e6a))
* **deps:** update all dependencies ([#129](https://github.com/defenseunicorns/terraform-aws-eks/issues/129)) ([c48fb40](https://github.com/defenseunicorns/terraform-aws-eks/commit/c48fb4022ebb767926d52be951473a2fd5dfef77))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v37.252.1 ([#126](https://github.com/defenseunicorns/terraform-aws-eks/issues/126)) ([6855291](https://github.com/defenseunicorns/terraform-aws-eks/commit/6855291084d8a6594c6e20f47000cb4b214d8d6d))
* remove efs-csi driver from blueprints addons ([#128](https://github.com/defenseunicorns/terraform-aws-eks/issues/128)) ([cd91cad](https://github.com/defenseunicorns/terraform-aws-eks/commit/cd91cad8de7b3d50716f76280152f22afdc56004))
* remove old artifacts, implement VPC subnetting patterns ([#127](https://github.com/defenseunicorns/terraform-aws-eks/issues/127)) ([469e7c9](https://github.com/defenseunicorns/terraform-aws-eks/commit/469e7c90c15e1d1ec4bd6b5c1d501217f7a1a4a0))


### Continuous Integration

* bump cluster_version to 1.29 ([#123](https://github.com/defenseunicorns/terraform-aws-eks/issues/123)) ([4e9433a](https://github.com/defenseunicorns/terraform-aws-eks/commit/4e9433ae8be0fe08355113e71ab26f3c31c494ec))

## [0.0.17](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.16...v0.0.17) (2024-03-15)


### Bug Fixes

* remove cluster version and bump to latest ([#122](https://github.com/defenseunicorns/terraform-aws-eks/issues/122)) ([d59054e](https://github.com/defenseunicorns/terraform-aws-eks/commit/d59054ee03330d5816ea3413e4a48c567d5ed07f))


### Miscellaneous Chores

* **deps:** update all dependencies ([#118](https://github.com/defenseunicorns/terraform-aws-eks/issues/118)) ([bfa2946](https://github.com/defenseunicorns/terraform-aws-eks/commit/bfa29460f1b3cab127aa02c020f09cec1c8fd5e4))
* **deps:** update all dependencies ([#120](https://github.com/defenseunicorns/terraform-aws-eks/issues/120)) ([d11c3d7](https://github.com/defenseunicorns/terraform-aws-eks/commit/d11c3d7fb6e628990a96ce6ea8c022a7b61b2321))

## [0.0.16](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.15...v0.0.16) (2024-02-23)


### Bug Fixes

* logic error for efs fsid ssm paramter count ([#116](https://github.com/defenseunicorns/terraform-aws-eks/issues/116)) ([ec7f72d](https://github.com/defenseunicorns/terraform-aws-eks/commit/ec7f72deb6cac6ae29f240873c291a79a10f0bf1))

## [0.0.15](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.14...v0.0.15) (2024-02-20)


### Features

* add ssm parameter for fileSystemId needed for efs StorageClass ([#113](https://github.com/defenseunicorns/terraform-aws-eks/issues/113)) ([6e1856a](https://github.com/defenseunicorns/terraform-aws-eks/commit/6e1856a733e4696eb11bc2df789880f53fa9fb52))


### Miscellaneous Chores

* **deps:** update all dependencies ([#111](https://github.com/defenseunicorns/terraform-aws-eks/issues/111)) ([2862888](https://github.com/defenseunicorns/terraform-aws-eks/commit/286288857124e0a9ad9b82a6bd8d7afce11dbd39))
* **deps:** update all dependencies ([#114](https://github.com/defenseunicorns/terraform-aws-eks/issues/114)) ([8b7a430](https://github.com/defenseunicorns/terraform-aws-eks/commit/8b7a430cb013378aa9955be0ad10dfffe6e66250))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.87.1 ([#115](https://github.com/defenseunicorns/terraform-aws-eks/issues/115)) ([334980f](https://github.com/defenseunicorns/terraform-aws-eks/commit/334980f977087bcdaa995d9a762c4e80a3778bfe))

## [0.0.14](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.13...v0.0.14) (2024-02-07)


### Features

* remove mandatory k8s touchpoints ([#110](https://github.com/defenseunicorns/terraform-aws-eks/issues/110)) ([55d7e4d](https://github.com/defenseunicorns/terraform-aws-eks/commit/55d7e4d72eba85d965d8a9ccfa460af422e46887))


### Bug Fixes

* **deps:** update all dependencies ([#104](https://github.com/defenseunicorns/terraform-aws-eks/issues/104)) ([d56ea7b](https://github.com/defenseunicorns/terraform-aws-eks/commit/d56ea7b03e330d0aa470337b41218bcea1396d16))


### Miscellaneous Chores

* **deps:** update all dependencies ([#101](https://github.com/defenseunicorns/terraform-aws-eks/issues/101)) ([4bc56b2](https://github.com/defenseunicorns/terraform-aws-eks/commit/4bc56b25c4600c320f54e678ac75db580b352207))
* **deps:** update all dependencies ([#106](https://github.com/defenseunicorns/terraform-aws-eks/issues/106)) ([7e57b22](https://github.com/defenseunicorns/terraform-aws-eks/commit/7e57b228bf2331a7788c109dd8397d5861df31b4))
* **deps:** update all dependencies ([#109](https://github.com/defenseunicorns/terraform-aws-eks/issues/109)) ([b1d6936](https://github.com/defenseunicorns/terraform-aws-eks/commit/b1d69362d3ce15c214f87ffcd9d134b39a629aec))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v37.132.1 ([#103](https://github.com/defenseunicorns/terraform-aws-eks/issues/103)) ([e3388e1](https://github.com/defenseunicorns/terraform-aws-eks/commit/e3388e1a0ddc7ab17917934c95d2519836c8a5dd))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v37.142.1 ([#105](https://github.com/defenseunicorns/terraform-aws-eks/issues/105)) ([074787a](https://github.com/defenseunicorns/terraform-aws-eks/commit/074787ad57054f0d606dfd046347c51209cc03a8))
* update eks module ([#107](https://github.com/defenseunicorns/terraform-aws-eks/issues/107)) ([07fdfaf](https://github.com/defenseunicorns/terraform-aws-eks/commit/07fdfaf25b7b86de84f6cc445d8eb22c5a737ef7))

## [0.0.13](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.12...v0.0.13) (2024-01-10)


### Features

* add ability to turn off helm-release resources and write values to ssm ([#97](https://github.com/defenseunicorns/terraform-aws-eks/issues/97)) ([ef16b23](https://github.com/defenseunicorns/terraform-aws-eks/commit/ef16b232618db8782c4c4ca57493ad7e74f4827d))


### Miscellaneous Chores

* **deps:** update all dependencies ([#95](https://github.com/defenseunicorns/terraform-aws-eks/issues/95)) ([c25ede0](https://github.com/defenseunicorns/terraform-aws-eks/commit/c25ede0ba813c248694306b96f0aa74e0c892b88))


### Continuous Integration

* renovate window update and vuln handling ([#100](https://github.com/defenseunicorns/terraform-aws-eks/issues/100)) ([6f877b9](https://github.com/defenseunicorns/terraform-aws-eks/commit/6f877b97948655cab5039cce47305228e256a2d5))
* update renovate window ([#91](https://github.com/defenseunicorns/terraform-aws-eks/issues/91)) ([0fd9ad5](https://github.com/defenseunicorns/terraform-aws-eks/commit/0fd9ad59120c84041e011cd8aae1f897532fbe65))

## [0.0.12](https://github.com/defenseunicorns/terraform-aws-eks/compare/v0.0.11...v0.0.12) (2023-11-27)


### Features

* add more dynamic logic for az ([#86](https://github.com/defenseunicorns/terraform-aws-eks/issues/86)) ([4846bed](https://github.com/defenseunicorns/terraform-aws-eks/commit/4846beded46325e1e822f11fa7ec0d757d735a27))


### Miscellaneous Chores

* **deps:** update all dependencies ([#83](https://github.com/defenseunicorns/terraform-aws-eks/issues/83)) ([7babada](https://github.com/defenseunicorns/terraform-aws-eks/commit/7babadaaa972c95b3090d72b7a15e0c1eaf877b7))
* **deps:** update all dependencies ([#90](https://github.com/defenseunicorns/terraform-aws-eks/issues/90)) ([ab1343f](https://github.com/defenseunicorns/terraform-aws-eks/commit/ab1343f8c2f76127c7ad5225461049266595c10c))
* remove uds references ([#80](https://github.com/defenseunicorns/terraform-aws-eks/issues/80)) ([c9dc3c2](https://github.com/defenseunicorns/terraform-aws-eks/commit/c9dc3c290c0040cb130fedabb0694de66753e8a7))


### Continuous Integration

* update renovate window ([#85](https://github.com/defenseunicorns/terraform-aws-eks/issues/85)) ([f31f3f8](https://github.com/defenseunicorns/terraform-aws-eks/commit/f31f3f889006f40a0932c2a9eb2bd202e0d11523))

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
