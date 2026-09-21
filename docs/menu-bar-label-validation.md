# Menu bar label: minimum width and centered content

Validated on 2026-09-22, starting from clean commit
`57a4c4296edc6eae386ed64159bc285ae53cf2aa` (0.2.3.11).

## Behavior and scope

The native `MenuBarExtra` previously measured an icon plus variable-length text.
Its monospaced font did not reserve space when the digit count changed.
The label now uses an `NSImage` drawing handler with a minimum logical width
measured from the widest existing status symbol, a three-point gap, and two
monospaced digits plus the degree sign. The complete icon/reading group is
centered. Readings wider than the minimum expand without reducing the font size.
The visible format remains `99°`; Celsius/Fahrenheit remains in the accessible
reading and tooltip. Display boundary tests stop at `999°`.

Observed native status-item sizes on this Mac (including system padding):

| Reading | Width | Height |
| --- | ---: | ---: |
| Missing, `9°`, `10°`, `49°`, `50°`, `99°` | 61 pt | 24 pt |
| `100°`, `212°`, `999°` | 69 pt | 24 pt |

These are measurements, not hard-coded platform constants. Crossing the
minimum can move neighboring items; one/two-digit changes do not change this
item's width. Other applications can still resize their own menu-bar items.

Normal images remain templates for native contrast. Images with an orange
daemon-update badge preserve color and redraw for the effective color scheme.
Only fonts/symbol assets are reused; there is no dynamic reading cache. The
existing idle/active/safety symbols, missing-data state and localized accessibility
modifiers are retained. Non-finite/unrepresentable display inputs are unavailable
instead of trapping during integer conversion.

Executable changes are confined to `MenuBarLabel`, moved into its own file.
The native scene, popup automatic height, menu controls, refresh mechanism,
temperature collection/conversion formula, fan control, versioning and
translations are unchanged. No custom `NSStatusItem`/`NSPopover` is introduced.

## Validation

- All 102 tests in 17 suites pass in Debug and Release, including five label
  tests. Pixel checks at 1x and 2x cover minimum/expanded dimensions, centering,
  clipping, orange badges, foreground contrast, units and unavailable inputs.
- Release localization packaging and strict ad-hoc signature verification pass.
- An isolated native application uses the production label and menu with
  `AppState(startServices: false)`. Its scene observes the state in the same way
  as the production app and republishes every 0.5 seconds. Synthetic display
  inputs cover 9/10, 49/50, 99/100, 999, Fahrenheit three-digit values, all three
  symbols, warnings and missing data. No synthetic values reach SMC or fan control.
- During these native display checks, the menu retains its window identity and
  complete footer. One/two-digit changes keep the window position stable. Warning
  and missing-data content change height, then restore the original height.
  Same-button close/reopen and dismissal by clicking another application pass.
- Light/dark transitions preserve the warning's orange color. The built-in
  Retina display and LG 4K display both pass at their current 2x backing scale.
  The isolated fixture's normal height is 465 pt with both old and new labels;
  it is not the fully packaged production app's height.
- The signed Release candidate actually ran with the existing daemon and real
  sensors. English, Simplified Chinese, Traditional Chinese, Celsius/Fahrenheit,
  Smart selection, enabled login item and repeated menu close/reopen pass. Its
  normal popup remains 260 x 449 pt, with ten-point top/bottom insets and six-point
  footer gaps. Twenty consecutive observations during genuine refresh retain
  window identity, position and size; input-event counts stayed unchanged during
  that observation, excluding outside clicks or typing as dismissal causes.
- The final candidate run (02:58:18–02:59:11, UTC+8) contains no new `[ERROR]`
  records in the application or daemon runtime logs.

Reproduction commands:

```sh
swift test
swift test -c release
bash Scripts/check-localization-package.sh "$(swift build -c release --show-bin-path)"
```

The machine is an M4 Max (Mac16,5), macOS 27.0 (26A428). Physical 1x displays,
other macOS versions, other hardware, VoiceOver speech output and prolonged
operation were not validated. Accessibility evidence is the native AX tree and
localized tooltip plus retained source modifiers. This is targeted UI acceptance,
not a guarantee against every native-menu or system configuration issue.

## Requested local recheck

A fresh Release build and signed candidate were tested again on 2026-09-22.
Application source hashes remained unchanged throughout this recheck.

- The actual app again passed English/Simplified Chinese/Traditional Chinese,
  Celsius/Fahrenheit, complete footer and menu close/reopen checks. Native label
  widths measured 61 pt for real two-digit Celsius readings and 69 pt for real
  three-digit Fahrenheit readings in all three languages.
- An initial observation ended when the global left-click count increased and
  the menu closed. That externally interrupted run is retained separately.
  The subsequent observation lasted 121.1 seconds with 100 samples and no input
  events. Real readings ranged from 49 to 79 degrees Celsius; the label stayed
  61 x 24 pt and the same native window retained its position and 260 x 449 pt
  dimensions. Closing and reopening after the observation passed as well.
- The separately rebuilt display fixture passed 41 native checks: 9/10, 49/50,
  99/100, 999, Fahrenheit 212, idle/active/safety symbols, missing data, warnings,
  automatic height recovery, repeated close/reopen, both physical displays at
  2x, and light/dark appearances. These inputs did not enter the real controller.
- Between 03:07:47 and 03:13:13 (UTC+8), 1,821 application and 4,483 daemon
  runtime records contained no new `[ERROR]` entries. Neither diagnostic-report
  directory contained a new ThermalForge crash report for the test window.
- The fixture was stopped and the installed app restored. Installed executable,
  CLI and daemon-plist hashes matched the pre-test snapshot. Exported application
  preferences matched exactly, and the original appearance was restored. The
  daemon still responded as 0.2.3.11. No product-code change was needed.

Evidence is in the `local-recheck-20260922-030617` subdirectory of the local audit
directory below; `summary.json` records the final checks. This is a bounded local
observation and does not extend the platform or long-duration coverage above.

## Development-test local state

The candidate was run from an isolated application bundle. The installed
0.2.3.11 app was restored afterward; its executable, root CLI and daemon plist
hashes are unchanged. Smart, system language, Celsius and the login setting are
preserved. The ordinary next-update-check timestamp advanced naturally. Test
fixtures have been stopped. That development-test stage did not include a
release, Homebrew update or remote push. Subsequent publication and installation
are recorded in [the 0.2.3.12 release validation](thermalforgepro-0.2.3.12-validation.md).
Detailed local evidence is under
`~/Library/Application Support/ThermalForgePro/menu-label-20260922/`.

## References

- Apple's [NSImage drawing handler](https://developer.apple.com/documentation/appkit/nsimage/init(size:flipped:drawinghandler:)) and [template image behavior](https://developer.apple.com/documentation/appkit/nsimage/istemplate).
- [Stats Stack](https://github.com/exelban/stats/blob/a9bf99866eac97d62e8952c058961f6c5e51bc67/Kit/Widgets/Stack.swift#L158-L189) treats monospaced digits and reserved width separately.
- Repository history `4561c4d`, `b0d6eb24`, and `8fdc1c38` records the previous custom status-item architecture and restoration of native `MenuBarExtra`; this change retains the native architecture.
