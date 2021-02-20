// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Lightbeam/Lightbeam Soft" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Width ("Width", Float) = 8.71
		_Tweak ("Tweak", Float) = 0.65
		_SoftEdge ("Soft Edge", Float) = 0.8


	}
	SubShader {
		//Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "Lightbeam" = "True"}

		Tags { "Queue"="AlphaTest+49" "Lightbeam" = "True"   "IgnoreProjector" = "True"}
		LOD 100
		Pass {

			Tags { "LightMode"="ForwardBase"} //第一步//
			Cull Back

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Lighting Off
			
			CGPROGRAM

			#pragma multi_compile_fwdbase//第二步//

			
			#pragma multi_compile __ LIGHT_BEAM_DEPTH
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "AutoLight.cginc" //第三步// 
			
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			fixed4 _Color;
			fixed _Width;
			fixed _Tweak;
			fixed _SoftEdge;

			struct v2f 
			{
			    float4 pos : SV_POSITION;
			    float4 uv : TEXCOORD0;
			    float4 falloffUVs : TEXCOORD1;
			    float4 screenPos : TEXCOORD2;
				float3 viewVec : TEXCOORD3;
				#if LIGHT_BEAM_DEPTH
			
				 
				UNITY_LIGHTING_COORDS(4,5)//第四步// 

				float4 worldPos : TEXCOORD6;
				float2 uvs : TEXCOORD7;
				float dep: TEXCOORD8;
				#endif
			};
			#if LIGHT_BEAM_DEPTH

			sampler2D LightbeamDepth;
			float4 LightbeamDepth_ST;
			float4x4 _WorldToLightbeam;
			#endif
			v2f vert (appdata_tan v)
			{
			    v2f o;			    		
			    o.pos = UnityObjectToClipPos( v.vertex );
								
				// Generate the falloff texture UVs
				TANGENT_SPACE_ROTATION;
				float3 refVector = mul(rotation, normalize(ObjSpaceViewDir(v.vertex)));

				fixed z = sqrt((refVector.z + _Tweak) * _Width);
				fixed x = (refVector.x / z) + 0.5;
				fixed y = (refVector.y / z) + 0.5;

				fixed2 uv1 = float2(x, v.texcoord.y);
				fixed2 uv2 = float2(x, y);
				o.falloffUVs = fixed4(uv1, uv2);
				
				o.screenPos = ComputeScreenPos(o.pos);

			 

				
				 

				COMPUTE_EYEDEPTH(o.screenPos.z);

				#if LIGHT_BEAM_DEPTH
				// NDC position
				float4 ndcPos = (o.screenPos / o.screenPos.w) * 2 - 1;

				// Camera parameter
				float far = _ProjectionParams.z;

				// View space vector pointing to the far plane
				float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
				o.viewVec = mul(unity_CameraInvProjection, clipVec.xyzz).xyz;


				float4 wpos = mul(unity_ObjectToWorld, float4(v.vertex.xyz,1));
				
				float4 lv_pos =   mul(_WorldToLightbeam, wpos); 
				lv_pos.xy /= lv_pos.w;
				float2 uvs =  float2( (lv_pos.x+1)/2  , (lv_pos.y+1)/2);
				uvs.y = 1-uvs.y;
				 
				 float dep =  lv_pos.z / lv_pos.w;
				o.worldPos =wpos;

				o.uvs = uvs;
				o.dep = dep;
			 
				TRANSFER_VERTEX_TO_FRAGMENT(o); //第5步// 
				#endif


				
								
			    return o;
			}
			
			
			fixed4 frag( v2f i ) : COLOR
			{			
				fixed falloff1 = tex2D(_MainTex, i.falloffUVs.xy).r;
				fixed falloff2 = tex2D(_MainTex, i.falloffUVs.zw).g;
				
				fixed4 c = _Color;
				c.a *= falloff1 * falloff2;
											
				// Soft Edges
				float4 depth = tex2Dproj(_CameraDepthTexture, i.screenPos);
				fixed destDepth = LinearEyeDepth(depth);
				fixed diff = saturate((destDepth - i.screenPos.z) * _SoftEdge);				
				c.a *= diff;
				c.a *=  saturate(i.screenPos.z * 0.2);

				
				#if LIGHT_BEAM_DEPTH

				 
				//UNITY_LIGHT_ATTENUATION(atten0, i, i.worldPos.xyz)
				//c.a *= atten0;
				//return float4(atten0.xxx,1);


				//float4 lv_pos =   mul(_WorldToLightbeam, wpos); 
				//lv_pos.xy /= lv_pos.w;
				//float2 uvs =  float2( (lv_pos.x+1)/2  , (lv_pos.y+1)/2);
				//uvs.y = 1-uvs.y;
				
			 

 
				//return float4(i.uvs.xxx,1);
				
				 
				float4 c1 = tex2D(LightbeamDepth,  i.uvs);
 
				float dep2 =  DecodeFloatRGBA(c1);
				 
				if (   dep2 <=i.dep)
				{
					//c.a *= atten0;
					//return float4(1,0,0,1);
				}
				else
				{
					c.a *= 0;
					 
				}

				 

				#endif
				// Fade when near the camera
				

			    return c;
			}
			
			ENDCG
		}
	} 
	Fallback "Lightbeam/Lightbeam"
}
