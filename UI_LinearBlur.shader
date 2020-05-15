Shader "Custom/UI/LinearBlur"
{
    Properties
    {
        _Blur ("Blur", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _CameraOpaqueTexture;
            float4 _CameraOpaqueTexture_TexelSize;

            float _Blur;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

#if UNITY_UV_STARTS_AT_TOP
                o.uv = (o.vertex.xy + o.vertex.w) * 0.5;
#else
                o.uv = (o.vertex.xy * -1 + o.vertex.w) * 0.5;
#endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 finalColor;
                float sampleColors = pow(_Blur * 2 + 1, 2);
                
                for(int x = -_Blur; x <= _Blur; x++)
                {
                    for(int y = -_Blur; y <= _Blur; y++)
                    {
                        float2 uv = float2(i.uv.x + 1 / _ScreenParams.x * x, i.uv.y + 1 / _ScreenParams.y * y);
                        finalColor += tex2D(_CameraOpaqueTexture, uv);
                    } 
                }
                return finalColor / sampleColors;
            }
            ENDCG
        }
    }
}
