# ThermalForgePro 0.2.3.12 validation

This release reserves the menu-bar label's minimum width for an icon, two
monospaced digits and the degree sign, centering the complete group. Three-digit
readings may expand. The native menu and automatic popup height remain intact.
Fan control, sensor selection, logging and version comparison are unchanged.

The underlying implementation passed 102 tests in 17 suites in both Debug and
Release. Native candidate acceptance on M4 Max/macOS 27 includes 121 seconds of
uninterrupted real-temperature observation (100 samples), three languages,
Celsius/Fahrenheit, menu close/reopen, and 41 isolated display checks through
999 degrees. App and daemon runtime logs contained no new errors during that
acceptance window. See [the detailed display validation](menu-bar-label-validation.md)
for evidence, measurements and environment limits.

At this source revision, the versioned release is being prepared. GitHub CI,
downloaded-package acceptance, Homebrew and final installed-state results will
be recorded after verification. The distribution uses an ad-hoc signature.
