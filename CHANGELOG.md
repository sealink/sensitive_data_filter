# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
This changelog adheres to [Keep a CHANGELOG](http://keepachangelog.com/).

## Unreleased
- [TT-8626] Update to build with github actions / ruby 3.0 / rails 6.1

## [0.5.0]
- [TT-5815] Relax version dependencies and tested on latest ruby versions

## [0.4.1] - 2018-03-08
### Changed
- [TT-3686] Don't mutate env vars unless the key already exists

## [0.4.0] - 2018-01-18
### Changed
- [TT-3520] No longer clone the "env" middleware variable
- [TT-3521] filter action dispatch parameter fields
- [TT-3523] Update gem dependencies

## [0.3.0] - 2016-12-28
### Changed
- Allows whitelisting hash values based on the key
- Updates README for usage with Rails middleware stack

### Added
- Adds `original_env` and `filtered_env` properties to occurrence

## [0.2.4] - 2016-12-22
### Changed
- Does not match credit cards numbers that are part of alphanumerical strings

## [0.2.3] - 2016-12-22
### Fixed
- Ensures that the url returned by the occurrence is filtered

### Changed
- Does not match credit cards numbers that are part of longer numbers

## [0.2.2] - 2016-12-21
### Fixed
- Implements stricter credit cards pattern matching
- Matches unconventionally formatted credit cards
- Scans every sub string for credit cards

## [0.2.1] - 2016-12-19
### Changed
- Updates README for usage with Rails

### Fixed
- Handles JSON parsing exceptions gracefully

## [0.2.0] - 2016-12-13
### Added
- Occurrence exposes content type
- Support for different content types
- Native JSON parameter parsing
- Allows defining parameter parsers
- Scans and masks parameter keys
- Adds credit card brand validation

### Changed
- Occurrence now exposes query and body params separately

### Fixed
- Skips scanning of file uploads

## [0.1.0] - 2016-12-09
### Added
- Whitelisting of matches
- Initial release
