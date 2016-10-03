float BilateralWeight(float r, float depth, float center_d)
{
    const float blurSharpness = 4;
    const float blurSigma = 6 * 0.5f;
    const float blurFalloff = 1.0f / (2.0f * blurSigma * blurSigma);

    float ddiff = (depth - center_d) * blurSharpness;
    return exp2(-r * r * blurFalloff - ddiff * ddiff);
}

float4 ShadowMapBlurPS(float2 coord : TEXCOORD0, uniform sampler2D source, uniform float2 offset) : COLOR
{
    float4 center = tex2D(source, coord);
    center.y = abs(center.y);

    float2 sum = float2(center.x, 1);

    float2 offset1 = coord + offset;
    float2 offset2 = coord - offset;

    [unroll]
    for(int r = 1; r < SHADOW_BLUR_COUNT; r++)
    {        
        float2 shadow1 = tex2D(source, offset1).xy;
        float2 shadow2 = tex2D(source, offset2).xy;
        
        float bilateralWeight1 = BilateralWeight(r, abs(shadow1.y), center.y);
        float bilateralWeight2 = BilateralWeight(r, abs(shadow2.y), center.y);
        
        sum.x += shadow1.x * bilateralWeight1;
        sum.x += shadow2.x * bilateralWeight2;

        sum.y += bilateralWeight1;
        sum.y += bilateralWeight2;
        
        offset1 += offset;
        offset2 -= offset;
    }

    return float4(sum.x / sum.y, center.yzw);
}

float4 ShadowMapNoBlurPS(float2 coord : TEXCOORD0, uniform sampler2D source, uniform float2 offset) : COLOR
{
    return tex2D(source, coord);
}