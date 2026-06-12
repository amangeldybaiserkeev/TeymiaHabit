#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 shaderAnimation(float2 position, half4 color, float2 size, float time) {
    float2 resolution = size;
    float2 uv = (position * 2.0 - resolution) / min(resolution.x, resolution.y);
    float t = time * 0.05;
    float lineWidth = 0.002;

    float3 col = float3(0.0);
    for (int j = 0; j < 3; j++) {
        for (int i =0; i <5; i++) {
            col[j] += lineWidth * float(i * i) / abs(fract(t - 0.01 * float(j)
            + float(i) * 0.01) * 5.0 - length(uv) + fmod(uv.x + uv.y, 0.2));
        }
    }

    return half4(half3(col), 1.0);

}
