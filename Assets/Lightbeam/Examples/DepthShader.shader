Shader "Unlit/DepthShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			//Tags { "LightMode" = "ForwardBase" }
            //Tags { "LightMode" = "ShadowCaster"}
 
			//Cull Front
            CGPROGRAM
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster
            #include "UnityStandardShadow.cginc"
            ENDCG
        }
    }
}
