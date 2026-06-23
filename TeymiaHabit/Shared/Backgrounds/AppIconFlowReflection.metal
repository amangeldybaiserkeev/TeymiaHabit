#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]]
half4 appIconFlowReflection(
        float2 position,
        SwiftUI::Layer layer,
        float contentHeight,
        float reflectionGap,
        float fade,
        float dim
) {
    // Если пиксель внутри иконки – оригинальный цвет
    if (position.y < contentHeight) {
        return layer.sample(position);
    }

    // Зазор между иконкой и отражением
    float start = contentHeight + reflectionGap;
    if (position.y < start) {
        return half4(0);
    }

    // Зеркальная позиция
    float poY = position.y - start;
    float2 pos = float2(position.x, contentHeight - poY);

    if (pos.y < 0.0) {
        return half4(0);
    }

    // ===== ГАУССОВСКОЕ РАЗМЫТИЕ =====
    float blurRadius = 2.0;          // Сила размытия (рекомендую 0.8…2.0)
    int kernelSize = 2;              // Радиус ядра (2 = 5x5 пикселей)
    half4 blurredColor = half4(0);
    float totalWeight = 0.0;

    for (int dx = -kernelSize; dx <= kernelSize; dx++) {
        for (int dy = -kernelSize; dy <= kernelSize; dy++) {
            float2 offset = float2(float(dx), float(dy)) * blurRadius;
            float2 samplePos = pos + offset;

            // Гауссовский вес: чем дальше от центра, тем меньше вес
            float weight = exp(-(float(dx*dx + dy*dy) / (2.0 * 1.5)));

            // Проверяем границы, чтобы не выйти за пределы иконки
            if (samplePos.x >= 0.0 && samplePos.x <= position.x &&
                samplePos.y >= 0.0 && samplePos.y <= contentHeight) {
                blurredColor += layer.sample(samplePos) * weight;
                totalWeight += weight;
            }
        }
    }

    half4 sampledColor = (totalWeight > 0.0) ? (blurredColor / totalWeight) : layer.sample(pos);

    // ===== ЗАТУХАНИЕ (без изменений) =====
    float progress = poY / contentHeight;
    float alpha = pow(1.0 - clamp(progress, 0.0, 1.0), fade);

    half4 color = (sampledColor * alpha) * half4(dim);
    return color;
}
