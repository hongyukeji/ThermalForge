import Foundation
import Metal

// Sustained GPU compute load: repeated large matrix-ish FMA kernel.
let src = """
#include <metal_stdlib>
using namespace metal;
kernel void burn(device float* buf [[buffer(0)]], uint gid [[thread_position_in_grid]]) {
    float a = buf[gid], b = a * 1.000001f + 0.5f;
    for (int i = 0; i < 4096; ++i) { a = fma(a, 1.0000001f, 0.000001f); b = fma(b, 0.9999999f, a); }
    buf[gid] = a + b;
}
"""
guard let dev = MTLCreateSystemDefaultDevice() else { print("no metal device"); exit(1) }
let lib = try! dev.makeLibrary(source: src, options: nil)
let fn = lib.makeFunction(name: "burn")!
let pipe = try! dev.makeComputePipelineState(function: fn)
let queue = dev.makeCommandQueue()!
let n = 1 << 20
let buf = dev.makeBuffer(length: n * 4, options: .storageModeShared)!
let seconds = CommandLine.arguments.count > 1 ? Double(CommandLine.arguments[1])! : 60
let deadline = Date().addingTimeInterval(seconds)
print("GPU load on \(dev.name) for \(Int(seconds))s")
while Date() < deadline {
    let cb = queue.makeCommandBuffer()!
    let enc = cb.makeComputeCommandEncoder()!
    enc.setComputePipelineState(pipe)
    enc.setBuffer(buf, offset: 0, index: 0)
    enc.dispatchThreads(MTLSize(width: n, height: 1, depth: 1),
                        threadsPerThreadgroup: MTLSize(width: pipe.maxTotalThreadsPerThreadgroup, height: 1, depth: 1))
    enc.endEncoding()
    cb.commit()
    cb.waitUntilCompleted()
}
print("done")
