# Fork audit and local acceptance: 2026-09-21

Build **0.2.3.6** follows official main **8a344f63a4b832f434c833d2143b3d41fa0ddd4a**, whose executable sources match the v0.2.3 release (`3fbaa527`). The later official commits are documentation changes. This is a fork build, not an official release. This audit supersedes the broader 0.2.3.5 adoption report preserved in commit `f3d2f8d` and the local installation records.

## Retained differences

| Difference | Reason and evidence | Remaining scope |
| --- | --- | --- |
| Original M4 acquisition and transport repair, submitted as [PR #54](https://github.com/ProducerGuy/ThermalForge/pull/54) | This Mac actually takes longer than the old two-second client deadline, and sometimes longer than ten seconds, to acquire stopped fans. Historical cold runs include 14.614 seconds with 282 successful concurrent liveness queries. Socket tests reproduce late replies, peer disconnect/SIGPIPE and independent read/write deadlines. | One shared 20-second acquisition budget, 30-second hardware-request timeout, existing two-second liveness budget, framed I/O fixes, SIGPIPE protection and already-manual fast path. Hardware serialization stays intact. |
| Minimal automatic release checking, inspired by [PR #30](https://github.com/ProducerGuy/ThermalForge/pull/30) | Official `resetAuto()` discards every `writeKey` result and logs success even if required mode/Ftst writes fail. Injected failures reproduce manual/unreadable states incorrectly being treated as success. This is a false acknowledgement of safety recovery. | Attempt all fan and Ftst writes, then report unconfirmed required failures. RPM targets remain advisory. This does not claim a physical failed release was forced on this Mac. |
| Fresh readback for rejected redundant releases | During local installation a stopped M4 rejected `F0Md=0` while already in firmware system mode. A naive adoption of #30 caused a false failure; this extra error was introduced by stricter checking, not present as an error in official code. | After all writes, accept rejected mode/Ftst writes only if fresh reads confirm automatic/system mode 0/3 or cleared Ftst 0. Manual, unknown and unreadable results still fail. Seven release tests cover these boundaries. |
| SMC read validity checks | The retained handoff fast path and release confirmation depend on trustworthy reads. Official reads check IOKit status but omit the separate firmware result; zero-initialized response bytes can otherwise masquerade as automatic mode. Three injected-call tests reproduce that return combination, malformed sizes and fresh reads. | Check both return statuses and payload size; mode/flag reads require one byte. No metadata cache, added polling or changed sensor list. The injected-call initializer is test support only. |
| Profile-test directory isolation, subset of [PR #47](https://github.com/ProducerGuy/ThermalForge/pull/47) | The official `saveLoad` test writes and deletes the real `profiles/test_custom.json`, overwriting an existing profile with that ID. This trigger is directly present in official test code. | Optional directory parameters and a unique temporary directory for the test. Production paths/JSON and the available profile UI are unchanged. No custom-profile feature. |
| User-requested GUI localization | English, Simplified Chinese and Traditional Chinese; ordered system matching and English fallback; immediate, persistent manual selection; localized status, warnings and accessibility text. | Presentation module/resources, small SwiftUI wrappers, app assembler/CI packaging check and isolated presentation tests. Traditional Chinese is a literal script conversion of the Simplified Chinese wording. See [maintenance instructions](gui-localization.md). |

## Removed differences

| Previously adopted work | Final disposition |
| --- | --- |
| [#51](https://github.com/ProducerGuy/ThermalForge/pull/51) self-drawn fixed-width menu bar, local spacing changes and AppKit startup patch | Removed together. Restore official `MenuBarExtra.window`, label `HStack(spacing: 3)`, natural digit width and original app lifecycle. The empty Settings window was introduced by the replacement architecture; its workaround is no reason to retain that architecture. |
| [#50](https://github.com/ProducerGuy/ThermalForge/pull/50) status-item manager integration | Removed with the replacement architecture. Native localized accessibility/help text remains part of the requested language feature; no claim of third-party menu-manager acceptance. |
| [#11](https://github.com/ProducerGuy/ThermalForge/pull/11) SMC metadata cache | Removed. The 9.8% read microbenchmark did not prove better application CPU, temperature, noise or inference throughput. Cache implementation and tests are gone. |
| [#44](https://github.com/ProducerGuy/ThermalForge/pull/44) explicit profile buttons/reselection guards | Removed. Restore the official Picker and selection behavior, including Silent. No verified local need to alter those semantics; no proposed 85°C rule. |
| [#48](https://github.com/ProducerGuy/ThermalForge/pull/48) and local Smart/wake adaptations | Removed in full. Restore official ThermalMonitor, Logger, wake recovery, thermal-floor handling and watchdog. Prior simulated tests and unchanged numeric constants did not establish the necessity of changing control behavior. The extra recovery helpers/tests added during this audit were also removed before installation. |

The final runtime difference in AppState is an opt-out used only by offscreen tests so they never start services or issue commands; production keeps the default upstream initialization and actions. Core profile constants, CPU/GPU sensor selection, 100ms sampling and 95°C safety threshold remain official. CLI text, logs, commands, profile IDs and protocol/JSON fields remain English and unchanged. Version metadata and fork documentation are the other necessary bookkeeping differences.

All rollback is incremental: previous commits remain reachable, and the pending audit state was separately archived before alignment. No history rewriting or force-push. There were no unrelated user changes in this checkout.

## Pre-install verification

- **73 tests in 13 suites passed**, including original transport coverage, release/read validity, profile persistence isolation and three-language presentation/fallback tests.
- Release build and app assembly passed. CI now validates localization copying and rejects missing resources before replacing an existing destination.
- A separate harmless probe executable linked only to the localization module was run inside a cloned app. A fixture-only translation marker was read from that app's own resource bundle; a deleted Chinese row fell back to English even while the build resources remained present. The real app resources were not edited.
- Offscreen panels cover normal, CLI hold/update, mismatch/safety and daemon-down states in all three languages. Synthetic 100°C values are rendering fixtures, not physical heating tests.

## Installed validation

The app, CLI and running daemon all report **0.2.3.6**. Installed executable hashes, all three resource files, ad-hoc signature, the unchanged launchd plist and the Homebrew CLI symlink were verified. Login registration remains enabled/allowed. The only preference delta from the backed-up 0.2.3.5 installation is `guiLanguage=system`; saved Smart and Celsius remain intact.

Real menu interaction switched through English, Simplified and Traditional Chinese while a test CLI hold requested 3000 RPM. Every switch preserved the app/daemon PIDs, exact daemon hold and saved profile. Live two-/three-digit Celsius/Fahrenheit labels naturally occupied 62/68 points on the tested display. Normal Quit/reopen retained Traditional Chinese and the CLI hold; Follow System then resolved to Simplified Chinese. The restored official Picker selected Balanced successfully, after which Smart and Celsius were restored. Launch had no ordinary blank window. A UI test helper initially treated the AX target disappearing during successful Quit as a failure; the follow-up verified actual process exit, relaunch and preserved ownership rather than suppressing the assertion.

One completed cold-fan test on this build measured:

| Measurement | Result |
| --- | ---: |
| Starting physical RPM | 0 / 0, firmware system mode |
| Cold acquisition, including command launch/polling | 8.094 s |
| Concurrent version/state/heartbeat queries | 156 successful, zero errors |
| Maximum query duration | 3.131 ms |
| Physical maximum RPM after five seconds | 5,836 / 5,799 |
| Repeated target commands, including CLI launch | 10.216–11.308 ms |

The test cleared its CLI hold, reopened saved Smart and confirmed stopped fans. An earlier preparation attempt crossed its conservative 70°C maintenance guard, stopped before issuing maximum speed and restored Smart; it is retained as an aborted preparation, not counted as a pass.

A separate **30-second Metal GPU workload** left Smart in control, with no fan commands or extra heartbeat injection. GPU rose from approximately 44.5°C to **75.6°C**, CPU peaked at **78.2°C**, fans first became nonzero around **13.2 seconds**, manual mode appeared around **15.4 seconds**, and measured RPM peaked at **5,007**. All **120** concurrent version/state queries succeeded, at most **2.035 ms**. The 88°C workload-stop threshold was not reached.

After the workload, Smart reduced fans to about 1,350 RPM at 52°C. CPU temperature then repeatedly rose again, reaching 82.1°C in the sampled post-load window, and Smart increased RPM in response. Thus the scripted **120-second cooldown assertion did not pass**; do not represent that script as wholly successful. A follow-up passive observation at about **149 seconds after workload completion**, without additional fan commands, confirmed CPU **49.7°C**, GPU **45.6°C**, both fans **0 RPM/system mode**, and no daemon hold. This establishes eventual recovery under the observed background activity, not a guaranteed idle cooldown time.

The daemon PID remained **45530**, launchd reported **runs = 1 / never exited**, and no new app `[ERROR]` occurred during the final installation tests. The final app PID after intentional UI/cold-test reopen was **50070**, unchanged through the GPU test. This is bounded functional verification. Real sleep/wake, reboot, sustained inference, physical 95°C thermal-floor triggering and third-party menu-manager compatibility were not tested. No inference settings, model parameters or power profiles were changed.

Detailed logs, screenshots, hashes, preferences, the previous 0.2.3.5 app/CLI and a syntax-checked (not executed) rollback script are retained in the local `update-20260921.pp1eetkt` installation record. The earlier 0.2.3.2/0.2.3.5 records remain historical evidence.

## Official contribution

[ProducerGuy/ThermalForge PR #54](https://github.com/ProducerGuy/ThermalForge/pull/54) is open and unmerged, with head `246d1bd5f3d0cdd6613217719541d9ae9a8a8593` at the latest API check. Its six implementation/test files contain only the original M4 repair. The isolated upstream checkout passed a release build and 56 tests, excluding the original test that writes user configuration. Localization and this fork's separate audit changes are not silently bundled into that submission. Submission does not mean upstream acceptance.
