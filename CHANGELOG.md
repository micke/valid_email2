# Changelog

## [7.0.13](https://github.com/micke/valid_email2/compare/v7.0.12...v7.0.13) (2025-05-08)


### Bug Fixes

* .co domains ([2a6c63c](https://github.com/micke/valid_email2/commit/2a6c63c4ee510fd230d820f6859fc9752f7bd372))

## [7.0.12](https://github.com/micke/valid_email2/compare/v7.0.11...v7.0.12) (2025-03-01)


### Bug Fixes

* re-add mx_server_is_in?(domain_list) for backwards compatibility ([#291](https://github.com/micke/valid_email2/issues/291)) ([5b0f979](https://github.com/micke/valid_email2/commit/5b0f9798e733456d885d4ee05c6b74de5d3d79e1))

## [7.0.11](https://github.com/micke/valid_email2/compare/v7.0.10...v7.0.11) (2025-02-28)


### Bug Fixes

* check if this actually fetches the tags ([be13649](https://github.com/micke/valid_email2/commit/be136494407c0731ef38e9ef958795f9aec0bcaa))

## [7.0.10](https://github.com/micke/valid_email2/compare/v7.0.9...v7.0.10) (2025-02-25)


### Bug Fixes

* remove buildingradar.com ([7c86044](https://github.com/micke/valid_email2/commit/7c860448804638f12b484d20e5973e8a8acc5e1d))

## [7.0.9](https://github.com/micke/valid_email2/compare/v7.0.8...v7.0.9) (2025-02-14)


### Bug Fixes

* just trigger a release build ([3a3f0e0](https://github.com/micke/valid_email2/commit/3a3f0e045df1938121cfa47f5a538f09a2b89d81))

## [7.0.8](https://github.com/micke/valid_email2/compare/v7.0.7...v7.0.8) (2025-02-14)


### Bug Fixes

* checkout new version ([9906824](https://github.com/micke/valid_email2/commit/990682433d176c00351eff056c28a6dd72cd6d8a))

## [7.0.7](https://github.com/micke/valid_email2/compare/v7.0.6...v7.0.7) (2025-02-14)


### Bug Fixes

* use a different ruby-version for release ([5d9465b](https://github.com/micke/valid_email2/commit/5d9465be9d32f685b78d14c56c822428e7d33580))

## [7.0.6](https://github.com/micke/valid_email2/compare/v7.0.5...v7.0.6) (2025-02-14)


### Bug Fixes

* check corrupted bundler cache ([290009b](https://github.com/micke/valid_email2/commit/290009b92c3e69fc668e473215ed08ff2fc5a48d))

## [7.0.5](https://github.com/micke/valid_email2/compare/v7.0.4...v7.0.5) (2025-02-14)


### Bug Fixes

* do not cache deps in release please ([a53f765](https://github.com/micke/valid_email2/commit/a53f76548eaf3c286763b73cfca6f6061fc88d28))

## [7.0.4](https://github.com/micke/valid_email2/compare/v7.0.3...v7.0.4) (2025-02-14)


### Bug Fixes

* pinning dependency for release task ([2f7d554](https://github.com/micke/valid_email2/commit/2f7d554bc5c18d68e56a1abdcb52957443ad6288))

## [7.0.3](https://github.com/micke/valid_email2/compare/v7.0.2...v7.0.3) (2025-02-13)


### Bug Fixes

* Class level DNS cache ([#271](https://github.com/micke/valid_email2/issues/271)) ([50aad15](https://github.com/micke/valid_email2/commit/50aad153270287ee19fbd23c190758a55ad00920))

## [7.0.2](https://github.com/micke/valid_email2/compare/v7.0.1...v7.0.2) (2025-01-23)


### Bug Fixes

* Remove nytimes.com from list of disposable domains ([#267](https://github.com/micke/valid_email2/issues/267)) ([8173464](https://github.com/micke/valid_email2/commit/8173464e15c492556167d3227804976d3546d1b2))

## [7.0.1](https://github.com/micke/valid_email2/compare/v7.0.0...v7.0.1) (2024-12-02)


### Bug Fixes

* Add domain luxyss.com ([#264](https://github.com/micke/valid_email2/issues/264)) ([b04d316](https://github.com/micke/valid_email2/commit/b04d31680881cde8d1620b8f6233c05db10232ca))
* Update disposable domains from Yopmail ([#263](https://github.com/micke/valid_email2/issues/263)) ([fee055f](https://github.com/micke/valid_email2/commit/fee055f62294eb7991d9cd20ec04f0b27afdee45))

## [7.0.0](https://github.com/micke/valid_email2/compare/v6.0.0...v7.0.0) (2024-11-19)


### ⚠ BREAKING CHANGES

* revert allowing scandinavian characters by making allowed multibyte characters configurable ([#261](https://github.com/micke/valid_email2/issues/261))

### Bug Fixes

* revert allowing scandinavian characters by making allowed multibyte characters configurable ([#261](https://github.com/micke/valid_email2/issues/261)) ([cf6a1e9](https://github.com/micke/valid_email2/commit/cf6a1e9e28f78e0c6f3e3ea7e9160bf9194b45e6))

## [6.0.0](https://github.com/micke/valid_email2/compare/v5.3.0...v6.0.0) (2024-11-03)


### ⚠ BREAKING CHANGES

* Remove deprecated methods and options

### Features

* Cache DNS lookups ([#256](https://github.com/micke/valid_email2/issues/256)) ([72115ec](https://github.com/micke/valid_email2/commit/72115ec1b866e54b5a4d530d7eaeb7e52a3c8e98))
* Remove deprecated methods and options ([1a29d27](https://github.com/micke/valid_email2/commit/1a29d27d587a39d181dfe2b6f39028bc317aff52))


### Bug Fixes

* disallow # in domain ([#259](https://github.com/micke/valid_email2/issues/259)) ([1643323](https://github.com/micke/valid_email2/commit/1643323fa3da8973cb63a727410aa9696706e3c8))
* **email_validator:** handle trailing whitespace in emails ([#255](https://github.com/micke/valid_email2/issues/255)) ([a06fdf7](https://github.com/micke/valid_email2/commit/a06fdf72cfc0df51c81057c6094aba332b692741))
* Falsely detecting Scandinavian characters as emojis ([#257](https://github.com/micke/valid_email2/issues/257)) ([e64de5c](https://github.com/micke/valid_email2/commit/e64de5c675a015c09c7e6b89bb4f65a39137f48f))
* typo in readme about config file to deny email domains ([#254](https://github.com/micke/valid_email2/issues/254)) ([a39ed57](https://github.com/micke/valid_email2/commit/a39ed5792a9d46abd954fceff929770eabf99a73))

## [5.3.0](https://github.com/micke/valid_email2/compare/v5.2.6...v5.3.0) (2024-08-31)


### Features

* Deprecate blacklist and whitelist naming ([9df0bf8](https://github.com/micke/valid_email2/commit/9df0bf8c9912721b007e5a6acc67f533ca560c9f))
* Warn when loading deprecated files ([46634df](https://github.com/micke/valid_email2/commit/46634dff409f9a47f10684d629dc022b22daf362))

## [5.2.6](https://github.com/micke/valid_email2/compare/v5.2.5...v5.2.6) (2024-08-10)


### Bug Fixes

* add .release-please-manifest.json ([8a9ef25](https://github.com/micke/valid_email2/commit/8a9ef25b77db3942956bb4790627b14eadc2404e))
* add id to release-please-action ([35b4697](https://github.com/micke/valid_email2/commit/35b4697b1970ebd696b7cdaf38889ec7b674000c))
* add release-please-config.json ([adde8b6](https://github.com/micke/valid_email2/commit/adde8b6fe23e3bdf8b892290b565f560d7e72c8d))
* Add step to publish gem to rubygems to the release action ([b6932f3](https://github.com/micke/valid_email2/commit/b6932f36c0a6af9897d723d222145678c9bc0f06))
* fetch tags when checking out the repository ([0d6ed8b](https://github.com/micke/valid_email2/commit/0d6ed8bd5e51d50eeb8f2315b6bc9803bf1d34da))
* reset the version to 5.2.5 ([b0cb66c](https://github.com/micke/valid_email2/commit/b0cb66c57cd08f0ecef72bb0dd84d4f5636adf41))
* Whitelist directbox.com ([cf70737](https://github.com/micke/valid_email2/commit/cf707371735c10b565ab3aafce39d7ea7089cdb1))

## Changelog

## Version 5.2.5
* Remove false positives [#240](https://github.com/micke/valid_email2/issue/240)
* Pull new domains

## Version 5.2.4
* Remove false positives [#236](https://github.com/micke/valid_email2/pull/236) [#237](https://github.com/micke/valid_email2/pull/237) [#239](https://github.com/micke/valid_email2/pull/239)
* Pull new domains

## Version 5.2.3
* Remove privaterelay.appleid.com.

## Version 5.2.2
* Pull new domains
* Remove addy.io and associated and ignor them.

## Version 5.2.1
* Remov false positive [#231](https://github.com/micke/valid_email2/pull/231)

## Version 5.2.0
* Allow configuration of DNS nameserver [#230](https://github.com/micke/valid_email2/pull/230)

## Version 5.1.1
* Remove false positives [#223](https://github.com/micke/valid_email2/issues/223)

## Version 5.1.0
* Allow dynamic validaton error messages [#221](https://github.com/micke/valid_email2/pull/221)

## Version 5.0.5
* Remove false positive duck.com

## Version 5.0.4
* Remove false positives:
  * https://github.com/micke/valid_email2/pull/212
  * https://github.com/micke/valid_email2/pull/213
  * https://github.com/micke/valid_email2/pull/215

## Version 5.0.3
* Remove false positive mail.com [#210](https://github.com/micke/valid_email2/issues/210)
* Pull new domains

## Version 5.0.2
* Remove mozmail from disposable_email_domains [#203](https://github.com/micke/valid_email2/pull/203)

## Version 5.0.1
* Remove zoho from disposable_email_domains as it's a false positive

## Version 5.0.0
* Support Null MX [rfc7505](https://datatracker.ietf.org/doc/html/rfc7505) #206
* Pull new domains

## Version 4.0.6
* Remove false positives https://github.com/micke/valid_email2/pull/200
* Remove unused default option https://github.com/micke/valid_email2/pull/201
* Pull new domains

## Version 4.0.5
* Remove false positive mail2word.com
* Pull new domains

## Version 4.0.4
* Add new domains https://github.com/micke/valid_email2/pull/196
* Pull new domains

## Version 4.0.3
* Remove false positive (139.com) #188
* Pull new domains

## Version 4.0.2
* Remove false positive (freemail.hu) #187
* Pull new domains

## Version 4.0.1
* Remove false positives (onit.com, asics.com)
* Pull new domains

## Version 4.0.0
* Support setting a timout for DNS lookups and default to 5 seconds https://github.com/micke/valid_email2/pull/181

## Version 3.7.0
* Support validating arrays https://github.com/micke/valid_email2/pull/178
* Pull new domains
* Add new domain https://github.com/micke/valid_email2/pull/176

## Version 3.6.1
* Add new domain https://github.com/micke/valid_email2/pull/175
* Pull new domains

## Version 3.6.0
* Add strict_mx validation https://github.com/micke/valid_email2/pull/173

## Version 3.5.0
* Disallow emails starting with a dot https://github.com/micke/valid_email2/pull/170
* Add option to whitelist domains from MX check https://github.com/micke/valid_email2/pull/167
* Remove false positives

## Version 3.4.0
* Disallow consecutive dots https://github.com/micke/valid_email2/pull/163
* Add andyes.net https://github.com/micke/valid_email2/pull/162

## Version 3.3.1
* Fix some performance regressions (https://github.com/micke/valid_email2/pull/150)

## Version 3.3.0
* Allow multiple addresses separated by comma (https://github.com/micke/valid_email2/pull/156)
* Make prohibited_domain_characters_regex changeable (https://github.com/micke/valid_email2/pull/157)

## Version 3.2.5
* Remove false positives
* Pull new domains

## Version 3.2.4
* Remove false positives

## Version 3.2.3
* Disallow backtick (\`) in domain
* https://github.com/micke/valid_email2/pull/152
* https://github.com/micke/valid_email2/pull/151

## Version 3.2.2
* Disallow quote (') in domain

## Version 3.2.1
* Fix loading of blacklisted domains

## Version 3.2.0
* Add option to disallow dotted email addresses https://github.com/micke/valid_email2/pull/146
* Update list of disposable email domains with another 18,327 domains
* Switch to storing the disposable domains as a TXT file instead of YAML
  Loading it from a YAML file takes 50x longer and uses 9x the amount of RAM. (https://gist.github.com/micke/9ff549865863aa7251657f7b5a0235aa)

## Version 3.1.3
* Disallow `/` in addresses https://github.com/micke/valid_email2/pull/142
* Add option to only validate that domain is not in list of disposable emails https://github.com/micke/valid_email2/pull/141

## Version 3.1.2
* Disallow ` ` in addresses https://github.com/micke/valid_email2/pull/139

## Version 3.1.1
* Disallow domains starting or ending with `-` https://github.com/micke/valid_email2/pull/140

## Version 3.1.0
* Performance improvements https://github.com/micke/valid_email2/pull/137

## Version 3.0.5
* Addresses with a dot before the @ is not valid https://github.com/micke/valid_email2/pull/136

## Version 3.0.4
* https://github.com/micke/valid_email2/pull/133

## Version 3.0.3
* Remove .id.au from the list https://github.com/micke/valid_email2/issues/131

## Version 3.0.2
* Add displaosable email providers https://github.com/micke/valid_email2/pull/127 https://github.com/micke/valid_email2/pull/128 https://github.com/micke/valid_email2/pull/132
* Refine documentation https://github.com/micke/valid_email2/pull/130

## Version 3.0.1
Relax the restrictions on domain validation so that we allow unicode domains and
other non ASCII domains while still disallowing the domains we blocked before.

## Version 3.0.0
* Moved __and__ renamed blacklist and whitelist and disposable_emails. Moved from the vendor directory to
  the config directory.  
  `vendor/blacklist.yml` -> `config/blacklisted_email_domains.yml`  
  `vendor/whitelist.yml` -> `config/whitelisted_email_domains.yml`  
  `vendor/disposable_emails.yml` -> `config/disposable_email_domains.yml`

* Test if the MX server that a domain resolves to is present in the lists of
  disposable email domains. As suggested in issue [#95](https://github.com/micke/valid_email2/issues/95)

* Update disposable emails

## Version 2.3.1
Update disposable emails (https://github.com/micke/valid_email2/pull/122)

## Version 2.3.0
Add whitelist feature (https://github.com/lisinge/valid_email2/pull/119)  
Update disposable emails (https://github.com/lisinge/valid_email2/pull/116)

## Version 2.2.3
Update disposable emails #113
Remove false positives (yandex.com, naver.com, com.ar)

## Version 2.2.2
Remove false-positive 163.com (https://github.com/lisinge/valid_email2/issues/105)

## Version 2.2.1
Fix regression where `ValidEmail2::Address.new` couldn't handle the address
being nil (https://github.com/lisinge/valid_email2/issues/102)

## Version 2.2.0
Removed backwards-compatability shim  (https://github.com/lisinge/valid_email2/pull/79)  
Removed protonmail.com from disposable email domains (https://github.com/lisinge/valid_email2/pull/99)  
Update disposable email domains (https://github.com/lisinge/valid_email2/pull/100)  
Allow case of MX record fallback to A record (https://github.com/lisinge/valid_email2/pull/101)

## Version 2.1.2
Removed qq.com from disposable email domains

## Version 2.1.1
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/92)  
Removed false positive domains

## Version 2.1.0
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/85)  
Validate that the domain includes only allowed characters (https://github.com/lisinge/valid_email2/issues/88)

## Version 2.0.2
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/85)

## Version 2.0.1
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/82 and https://github.com/lisinge/valid_email2/pull/83)

## Version 2.0.0
Add validator namespaced under `ValidEmail2` https://github.com/lisinge/valid_email2/pull/79  
Deprecate global `EmailValidator` in favor of the namespaced one.

## Version 1.2.22
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/80)

## Version 1.2.21
Added More disposable email domains (https://github.com/lisinge/valid_email2/pull/77, https://github.com/lisinge/valid_email2/pull/78)

## Version 1.2.20
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/76)

## Version 1.2.19
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/73, https://github.com/lisinge/valid_email2/pull/74 and https://github.com/lisinge/valid_email2/pull/75)

## Version 1.2.18
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/70, https://github.com/lisinge/valid_email2/pull/71 and https://github.com/lisinge/valid_email2/pull/72)

## Version 1.2.17
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/70)

## Version 1.2.16
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/68, https://github.com/lisinge/valid_email2/pull/69 and https://github.com/lisinge/valid_email2/commit/2e512458c181eb4d95514320723a09781fb14485)

## Version 1.2.15
Removed disposable domains that are false positives (https://github.com/lisinge/valid_email2/pull/67)

## Version 1.2.14
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/66)

## Version 1.2.13
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/65)

## Version 1.2.12
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/64)

## Version 1.2.11
Properly test that domain is a proper domain and not just a TLD (https://github.com/lisinge/valid_email2/issues/63)

## Version 1.2.10
Improve performance in domain matching (https://github.com/lisinge/valid_email2/pull/62)
Add clipmail.eu (https://github.com/lisinge/valid_email2/pull/61)

## Version 1.2.9
Remove example.com (https://github.com/lisinge/valid_email2/issues/59)

## Version 1.2.8
Add maileme101.com (https://github.com/lisinge/valid_email2/pull/56)

## Version 1.2.7
Add throwam.com and pull updates from mailchecker.

## Version 1.2.6
Remove nus.edu.sg as it's a valid domain (https://github.com/lisinge/valid_email2/pull/54)

## Version 1.2.5
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/51, https://github.com/lisinge/valid_email2/pull/52 and https://github.com/lisinge/valid_email2/pull/53)

## Version 1.2.4
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/48, https://github.com/lisinge/valid_email2/pull/49 and https://github.com/lisinge/valid_email2/pull/50)

## Version 1.2.3
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/45)

## Version 1.2.2
Removed false positive email domains (https://github.com/lisinge/valid_email2/pull/43 and https://github.com/lisinge/valid_email2/pull/44)

## Version 1.2.1
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/41, https://github.com/lisinge/valid_email2/pull/42 and https://github.com/lisinge/valid_email2/commit/8b99a799dc126229d9bc4d79d473a0344e788d34)

## Version 1.2.0
Disposable email providers have started to use random subdomains so valid_email2
will now correctly match against subdomains https://github.com/lisinge/valid_email2/issues/40  
Updated list of disposable email providers.

## Version 1.1.13
Removed husmail.com and nevar.com from the disposable email list (https://github.com/lisinge/valid_email2/pull/38)

## Version 1.1.12
Removed fastmail.fm from the disposable email list (https://github.com/lisinge/valid_email2/pull/37)

## Version 1.1.11
Removed poczta.onet.pl from the disposable_emails list (https://github.com/lisinge/valid_email2/issues/34)
Added a whitelist to the internal pull_mailchecker_emails so that poczta.onet.pl
can't sneak back in again.

## Version 1.1.10
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/32)
Added script that pulls disposable emails (https://github.com/lisinge/valid_email2/pull/33)

## Version 1.1.9
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/22,
https://github.com/lisinge/valid_email2/pull/23, https://github.com/lisinge/valid_email2/pull/24,
https://github.com/lisinge/valid_email2/pull/25, https://github.com/lisinge/valid_email2/pull/26,
https://github.com/lisinge/valid_email2/pull/27, https://github.com/lisinge/valid_email2/pull/29
and https://github.com/lisinge/valid_email2/pull/30)

## Version 1.1.8
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/21)

## Version 1.1.7
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/18 and https://github.com/lisinge/valid_email2/pull/19)

## Version 1.1.6
Fix a regression which changed validation on domains that caused domains with
multiple consecutive dots to be valid.

## Version 1.1.5
Be more lenient on the mail gem version dependency to allow people to use v2.6.
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/14 and https://github.com/lisinge/valid_email2/pull/15)

## Version 1.1.4
Added more disposable email domains (https://github.com/lisinge/valid_email2/commit/aedb51fadd5a05461d7f5ef7ea6942d7769f0c58)

## Version 1.1.3
Added more disposable email domains (https://github.com/lisinge/valid_email2/commit/a29ce30d4bc22a23283a0b3f9f6d4560309784ca)

## Version 1.1.2
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/11 and https://github.com/lisinge/valid_email2/pull/13 and https://github.com/lisinge/valid_email2/commit/81e20eb8a14759b88dfee3c343e21512aa7d8da4)

## Version 1.1.1
Added more disposable email domains (https://github.com/lisinge/valid_email2/pull/9 and https://github.com/lisinge/valid_email2/pull/10)

## Version 1.1.0
Added support to locally blacklist emails

## Version 1.0.0

Moved EmailValidator to seperate file
