# Native menu spacing: 0.2.3.7

The FANS heading previously started immediately after its divider, while later headings received four points from their preceding dividers. Language and the two footer toggles also touched because the outer stack has zero spacing. This update responds to the user's marked screenshots.

The native panel now adds four points above FANS, matching the other headings; adds four points of vertical padding to the Smart/Default row, making eight points on each side of its adjacent dividers; and leaves six points between the language picker, temperature-unit toggle, login toggle and Quit. Controls retain their original order, horizontal padding, bindings and native styles. The panel remains 260 points wide. Only MenuBarView layout and version metadata changed in executable sources; fan control and localization text are unchanged.

Validation: the existing presentation test rendered four states in English, Simplified Chinese and Traditional Chinese (12 layouts), the release build passed, and the resource packaging/missing-resource checks passed. The installed app, CLI and running daemon all report 0.2.3.7; hashes, signature and the unchanged launchd plist were verified. Live AX measurements in all three languages confirm footer gaps of exactly 6/6/6 points and a 260×448-point panel. The app and daemon PIDs remained stable during the language checks, and the exported preferences match the backup exactly. The previous build's hardware measurements remain in [the 0.2.3.6 audit](upstream-followups-20260921.md); this spacing-only update does not require repeating a GPU workload.

## 0.2.3.8 follow-up

The last native Picker row had only the divider's four-point gap, while fan and temperature rows also contributed one point of bottom padding. Add one point below the profile Picker so Fan 1, Ambient and Max all leave five points before their following divider. Existing control styles, bindings and footer spacing are retained.

The installed 0.2.3.8 app was measured using live accessibility row bounds and divider pixels in its own window screenshots: all three gaps are 5 points in English, Simplified Chinese and Traditional Chinese. Footer gaps remain 6/6/6 points; the panel is 260×449 points. Preferences match the pre-update export, app/daemon PIDs remain stable during language checks, and installed app/CLI hashes, signature and daemon version were verified. Existing 12-state presentation coverage, release build and packaging checks passed.
