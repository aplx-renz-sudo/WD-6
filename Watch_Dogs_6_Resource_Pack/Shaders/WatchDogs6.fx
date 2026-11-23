#include "ReShade.fxh"

// Lightweight cinematic grade and warm-sky-only sunrise/sunset tint.
// One pass, one backbuffer sample, no textures, LUTs, glow taps, or extra targets.

uniform float SkyTintStrength <
    ui_label = "Sky tint strength";
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.48;

uniform float CinematicStrength <
    ui_label = "Cinematic grade strength";
    ui_type = "slider";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.44;

float3 Grade(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 color = tex2D(ReShade::BackBuffer, uv).rgb;
    float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
    // Tint only bright, already-warm pixels in the upper image. Blue daytime
    // skies and neutral clouds fail this test and keep their original color.
    // Warm source hues naturally occur at sunset and sunrise.
    float skyRegion = 1.0 - smoothstep(0.36, 0.51, uv.y);
    float brightMask = smoothstep(0.34, 0.64, luma);
    float warmSkyMask = smoothstep(0.055, 0.20, color.r - color.b)
                      * smoothstep(0.035, 0.16, color.g - color.b);
    float skyMask = skyRegion * brightMask * warmSkyMask;

    // Rose at the top, peach and gold at the lower edge of the sky mask.
    float horizon = smoothstep(0.08, 0.52, uv.y);
    float3 rose = float3(1.00, 0.55, 0.64);
    float3 gold = float3(1.00, 0.82, 0.58);
    float3 sunset = lerp(rose, gold, horizon);
    color = lerp(color, color * 0.72 + sunset * 0.28, skyMask * SkyTintStrength);

    // Add a restrained cool-shadow / warm-highlight film grade. Keep contrast
    // nearly neutral and gently roll off highlights to soften the lighting feel
    // without a blur pass or extra image samples.
    float gradeLuma = dot(color, float3(0.2126, 0.7152, 0.0722));
    float shadowWeight = 1.0 - smoothstep(0.08, 0.48, gradeLuma);
    float highlightWeight = smoothstep(0.48, 0.92, gradeLuma);
    float3 coolShadows = color * float3(0.975, 0.99, 1.02);
    float3 warmHighlights = color * float3(1.025, 1.008, 0.98);
    color = lerp(color, coolShadows, shadowWeight * CinematicStrength * 0.34);
    color = lerp(color, warmHighlights, highlightWeight * CinematicStrength * 0.38);
    color = (color - 0.5) * (1.0 - CinematicStrength * 0.035) + 0.5;
    float postLuma = dot(color, float3(0.2126, 0.7152, 0.0722));
    float highlightShoulder = max(postLuma - 0.68, 0.0);
    color *= 1.0 / (1.0 + highlightShoulder * CinematicStrength * 0.22);
    float3 gray = dot(color, float3(0.2126, 0.7152, 0.0722));
    color = lerp(gray, color, 1.0 + CinematicStrength * 0.015);
    return saturate(color);
}

technique Turn_on_Watch_Dogs_6 <
    ui_label = "Turn on Watch Dogs 6";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = Grade;
    }
}
