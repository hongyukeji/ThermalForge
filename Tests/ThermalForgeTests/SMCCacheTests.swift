import Foundation
import IOKit
import Testing
@testable import ThermalForgeCore

@Suite("SMC metadata cache — injected IOKit")
struct SMCCacheTests {
    @Test("Concurrent readers share one successful metadata lookup")
    func concurrentReaders() {
        let lock = NSLock()
        var metadata = 0
        var reads = 0
        let smc = SMCConnection { input, output in
            lock.lock()
            defer { lock.unlock() }
            if input.data8 == SMCCommand.readKeyInfo.rawValue {
                metadata += 1
                output.keyInfo.dataSize = 4
            } else { reads += 1 }
            return kIOReturnSuccess
        }
        DispatchQueue.concurrentPerform(iterations: 64) { _ in
            #expect(smc.readKey("Tg0j").success)
        }
        #expect(metadata == 1)
        #expect(reads == 64)
    }

    @Test("Repeated reads cache metadata but read fresh sensor bytes every time")
    func freshValues() {
        var metadata = 0
        var reads = 0
        let smc = SMCConnection { input, output in
            if input.data8 == SMCCommand.readKeyInfo.rawValue {
                metadata += 1
                output.keyInfo.dataSize = 4
            } else {
                reads += 1
                output.bytes.0 = UInt8(reads)
                #expect(input.keyInfo.dataSize == 4)
            }
            return kIOReturnSuccess
        }
        #expect(smc.readKey("Tg0j").bytes.first == 1)
        #expect(smc.readKey("Tg0j").bytes.first == 2)
        #expect(metadata == 1)
        #expect(reads == 2)
    }

    @Test("Transiently absent or failed metadata never hides a returning sensor")
    func retryMissing() {
        var attempts = 0
        let smc = SMCConnection { input, output in
            if input.data8 == SMCCommand.readKeyInfo.rawValue {
                attempts += 1
                if attempts == 1 { return kIOReturnError }
                output.keyInfo.dataSize = attempts == 2 ? 0 : 4
            }
            return kIOReturnSuccess
        }
        #expect(!smc.readKey("Tg0j").success)
        #expect(!smc.readKey("Tg0j").success)
        #expect(smc.readKey("Tg0j").success)
        #expect(smc.readKey("Tg0j").success)
        #expect(attempts == 3)
    }

    @Test("Firmware-rejected metadata is not cached")
    func rejectedMetadata() {
        var attempts = 0
        let smc = SMCConnection { input, output in
            if input.data8 == SMCCommand.readKeyInfo.rawValue {
                attempts += 1
                output.keyInfo.dataSize = 4
                output.result = 1
            }
            return kIOReturnSuccess
        }
        _ = smc.readKey("Tg0j")
        _ = smc.readKey("Tg0j")
        #expect(attempts == 2)
    }

    @Test("Metadata cache is per connection and never masks failed value reads")
    func readFailure() {
        for _ in 0..<2 {
            var metadata = 0
            var reads = 0
            let smc = SMCConnection { input, output in
                if input.data8 == SMCCommand.readKeyInfo.rawValue {
                    metadata += 1
                    output.keyInfo.dataSize = 4
                } else {
                    reads += 1
                    if reads == 1 { return kIOReturnError }
                }
                return kIOReturnSuccess
            }
            #expect(!smc.readKey("Tg0j").success)
            #expect(smc.readKey("Tg0j").success)
            #expect(metadata == 1)
        }
    }
}
