Shader "Lightbeam/DepthShader"
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
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#include "Shadow.cginc"
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 pos : TEXCOORD0;
				float4 wpos: TEXCOORD1;
				float2 uvs : TEXCOORD7;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform float4x4 _WorldToLightbeam;
			v2f vert (appdata v)
			{
				v2f o;
 
				float4 wpos = mul(unity_ObjectToWorld, float4(v.vertex.xyz,1));
				 
				//o.vertex = mul(_WorldToLightbeam, wpos); 
				o.vertex = UnityObjectToClipPos(v.vertex);
				//
				o.pos = o.vertex;
				o.wpos = wpos;

				float4 lv_pos =   mul(_WorldToLightbeam, wpos); 
				lv_pos.xy /= lv_pos.w;
				float2 uvs =  float2( (lv_pos.x+1)/2  , (lv_pos.y+1)/2);
				uvs.y = 1-uvs.y;

				o.uvs = uvs;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return float4(1,0,0,1);
				 
				float depth = i.pos.z /i.pos.w;
				//if(i.uvs.x>1)
				//return float4(0,0,1,1);
				//return float4(i.uvs.xy,0,1);
				return EncodeFloatRGBA(depth);
				 
			}
			ENDCG
		}
	}
}

 