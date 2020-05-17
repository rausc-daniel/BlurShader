Shader "Custom/Magnification"
{
    Properties
    {
        _Magnification("Magnification", Float) = 1
    }

    SubShader
    {
        // We need to be rendered after all opaque things have been rendered
        Tags{ "Queue" = "Transparent" "PreviewType" = "Plane" }
        LOD 100

        Pass
            {
                // We need to know whats behind our object
                ZTest On
                // This object should not be written to the ZBuffer, we want to be ignored by all other objects
                ZWrite Off
                // We don't want to receive or throw shadows
                Lighting Off
                Blend One Zero
                Fog { Mode Off }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Texture filled by Unity, contains the image that would be rendered without this shader
            sampler2D _CameraOpaqueTexture;
            half _Magnification;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Compute the center of our object in UV space
                float4 uv_center = ComputeGrabScreenPos(UnityObjectToClipPos(float4(0, 0, 0, 1)));
                // Compute the distance of the current vertex to the center in uv space
                float4 uv_diff = ComputeGrabScreenPos(o.vertex) - uv_center;
                // Account for magnification modifier
                uv_diff /= _Magnification;
                // Move uv away from center of the object to scale the texture  
                o.uv = uv_center + uv_diff;
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                // Sample the image at the newly calculated uv
                return tex2Dproj(_CameraOpaqueTexture, UNITY_PROJ_COORD(i.uv));
            }
            ENDCG
        }
    }
}