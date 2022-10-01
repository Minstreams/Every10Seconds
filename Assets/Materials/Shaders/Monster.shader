// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:Standard,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33921,y:33189,varname:node_9361,prsc:2|custl-580-OUT,alpha-1497-OUT,voffset-6092-OUT;n:type:ShaderForge.SFN_LightAttenuation,id:8068,x:32886,y:32984,varname:node_8068,prsc:2;n:type:ShaderForge.SFN_LightColor,id:3406,x:33081,y:33462,varname:node_3406,prsc:2;n:type:ShaderForge.SFN_Multiply,id:146,x:33094,y:33126,varname:node_146,prsc:2|A-8068-OUT,B-9728-OUT;n:type:ShaderForge.SFN_LightVector,id:5958,x:32519,y:33126,varname:node_5958,prsc:2;n:type:ShaderForge.SFN_NormalVector,id:8684,x:32519,y:33254,prsc:2,pt:False;n:type:ShaderForge.SFN_Dot,id:2867,x:32709,y:33126,varname:node_2867,prsc:2,dt:0|A-5958-OUT,B-8684-OUT;n:type:ShaderForge.SFN_Color,id:4369,x:33081,y:33635,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_4369,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:580,x:33446,y:33806,varname:node_580,prsc:2|A-3406-RGB,B-4369-RGB,C-5108-RGB;n:type:ShaderForge.SFN_Tex2d,id:5108,x:33081,y:33832,varname:node_5108,prsc:2,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False|UVIN-2284-UVOUT,TEX-2115-TEX;n:type:ShaderForge.SFN_TexCoord,id:7046,x:32634,y:33832,varname:node_7046,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Panner,id:2284,x:32852,y:33832,varname:node_2284,prsc:2,spu:0.1,spv:0.1|UVIN-7046-UVOUT;n:type:ShaderForge.SFN_Clamp01,id:9728,x:32886,y:33126,varname:node_9728,prsc:2|IN-2867-OUT;n:type:ShaderForge.SFN_Negate,id:3658,x:32709,y:33305,varname:node_3658,prsc:2|IN-2867-OUT;n:type:ShaderForge.SFN_Clamp01,id:7087,x:32886,y:33305,varname:node_7087,prsc:2|IN-3658-OUT;n:type:ShaderForge.SFN_Multiply,id:2961,x:33094,y:33305,varname:node_2961,prsc:2|A-7087-OUT,B-8068-OUT;n:type:ShaderForge.SFN_Add,id:1497,x:33407,y:33180,varname:node_1497,prsc:2|A-146-OUT,B-2961-OUT;n:type:ShaderForge.SFN_Slider,id:4378,x:33261,y:33527,ptovrint:False,ptlb:slider,ptin:_slider,varname:node_4378,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Tex2dAsset,id:2115,x:32634,y:34015,ptovrint:False,ptlb:Noise,ptin:_Noise,varname:node_2115,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Vector1,id:6120,x:32610,y:34199,varname:node_6120,prsc:2,v1:0.66;n:type:ShaderForge.SFN_Append,id:7627,x:33446,y:33969,varname:node_7627,prsc:2|A-5108-R,B-3728-G,C-6589-B;n:type:ShaderForge.SFN_Multiply,id:6092,x:33702,y:33603,varname:node_6092,prsc:2|A-4378-OUT,B-846-OUT;n:type:ShaderForge.SFN_Panner,id:1362,x:32852,y:34012,varname:node_1362,prsc:2,spu:1,spv:1|UVIN-2284-UVOUT,DIST-6120-OUT;n:type:ShaderForge.SFN_Tex2d,id:3728,x:33081,y:34022,varname:node_3728,prsc:2,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False|TEX-2115-TEX;n:type:ShaderForge.SFN_Panner,id:6723,x:32840,y:34237,varname:node_6723,prsc:2,spu:1,spv:1|UVIN-1362-UVOUT,DIST-6429-OUT;n:type:ShaderForge.SFN_Vector1,id:6429,x:32610,y:34310,varname:node_6429,prsc:2,v1:0.33;n:type:ShaderForge.SFN_Tex2d,id:6589,x:33081,y:34237,varname:node_6589,prsc:2,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False|UVIN-6723-UVOUT,TEX-2115-TEX;n:type:ShaderForge.SFN_RemapRange,id:846,x:33658,y:33895,varname:node_846,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-7627-OUT;proporder:4369-4378-2115;pass:END;sub:END;*/

Shader "Shader Forge/Monster" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _slider ("slider", Range(0, 1)) = 0
        _Noise ("Noise", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _MainColor;
            uniform float _slider;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_7584 = _Time;
                float2 node_2284 = (o.uv0+node_7584.g*float2(0.1,0.1));
                float4 node_5108 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(node_2284, _Noise),0.0,0));
                float4 node_3728 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(o.uv0, _Noise),0.0,0));
                float node_6429 = 0.33;
                float node_6120 = 0.66;
                float2 node_1362 = (node_2284+node_6120*float2(1,1));
                float2 node_6723 = (node_1362+node_6429*float2(1,1));
                float4 node_6589 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(node_6723, _Noise),0.0,0));
                float3 node_7627 = float3(node_5108.r,node_3728.g,node_6589.b);
                v.vertex.xyz += (_slider*(node_7627*2.0+-1.0));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
                float4 node_7584 = _Time;
                float2 node_2284 = (i.uv0+node_7584.g*float2(0.1,0.1));
                float4 node_5108 = tex2D(_Noise,TRANSFORM_TEX(node_2284, _Noise));
                float3 finalColor = (_LightColor0.rgb*_MainColor.rgb*node_5108.rgb);
                float node_2867 = dot(lightDirection,i.normalDir);
                float node_1497 = ((attenuation*saturate(node_2867))+(saturate((-1*node_2867))*attenuation));
                return fixed4(finalColor,node_1497);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdadd
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _MainColor;
            uniform float _slider;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_1080 = _Time;
                float2 node_2284 = (o.uv0+node_1080.g*float2(0.1,0.1));
                float4 node_5108 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(node_2284, _Noise),0.0,0));
                float4 node_3728 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(o.uv0, _Noise),0.0,0));
                float node_6429 = 0.33;
                float node_6120 = 0.66;
                float2 node_1362 = (node_2284+node_6120*float2(1,1));
                float2 node_6723 = (node_1362+node_6429*float2(1,1));
                float4 node_6589 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(node_6723, _Noise),0.0,0));
                float3 node_7627 = float3(node_5108.r,node_3728.g,node_6589.b);
                v.vertex.xyz += (_slider*(node_7627*2.0+-1.0));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float4 node_1080 = _Time;
                float2 node_2284 = (i.uv0+node_1080.g*float2(0.1,0.1));
                float4 node_5108 = tex2D(_Noise,TRANSFORM_TEX(node_2284, _Noise));
                float3 finalColor = (_LightColor0.rgb*_MainColor.rgb*node_5108.rgb);
                float node_2867 = dot(lightDirection,i.normalDir);
                float node_1497 = ((attenuation*saturate(node_2867))+(saturate((-1*node_2867))*attenuation));
                return fixed4(finalColor * node_1497,0);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float _slider;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float4 node_3213 = _Time;
                float2 node_2284 = (o.uv0+node_3213.g*float2(0.1,0.1));
                float4 node_5108 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(node_2284, _Noise),0.0,0));
                float4 node_3728 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(o.uv0, _Noise),0.0,0));
                float node_6429 = 0.33;
                float node_6120 = 0.66;
                float2 node_1362 = (node_2284+node_6120*float2(1,1));
                float2 node_6723 = (node_1362+node_6429*float2(1,1));
                float4 node_6589 = tex2Dlod(_Noise,float4(TRANSFORM_TEX(node_6723, _Noise),0.0,0));
                float3 node_7627 = float3(node_5108.r,node_3728.g,node_6589.b);
                v.vertex.xyz += (_slider*(node_7627*2.0+-1.0));
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Standard"
    CustomEditor "ShaderForgeMaterialInspector"
}
