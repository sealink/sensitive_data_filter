# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
This changelog adheres to [Keep a CHANGELOG](http://keepachangelog.com/).

## [Unreleased]
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
