// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:True,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:4795,x:32874,y:32641,varname:node_4795,prsc:2|custl-8376-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:32235,y:32601,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:3a5a96df060a5cf4a9cc0c59e13486b7,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2393,x:32509,y:32884,varname:node_2393,prsc:2|A-6074-RGB,B-2053-RGB,C-797-RGB,D-9248-OUT;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32235,y:32772,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32235,y:32930,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Vector1,id:9248,x:32235,y:33081,varname:node_9248,prsc:2,v1:2;n:type:ShaderForge.SFN_LightAttenuation,id:9989,x:32049,y:33282,varname:node_9989,prsc:2;n:type:ShaderForge.SFN_LightColor,id:2104,x:32049,y:33153,varname:node_2104,prsc:2;n:type:ShaderForge.SFN_Multiply,id:8376,x:32695,y:32884,varname:node_8376,prsc:2|A-2393-OUT,B-9225-OUT;n:type:ShaderForge.SFN_AmbientLight,id:5227,x:31672,y:33467,varname:node_5227,prsc:2;n:type:ShaderForge.SFN_Add,id:9225,x:32494,y:33152,varname:node_9225,prsc:2|A-6216-OUT,B-7815-OUT;n:type:ShaderForge.SFN_Code,id:7558,x:31916,y:33447,varname:node_7558,prsc:2,code:cgBlAHQAdQByAG4AIABTAGgAYQBkAGUAUwBIAFAAZQByAFAAaQB4AGUAbAAoAHcAbwByAGwAZABOAG8AcgBtAGEAbAAsACAAYwB1AHIAcgBlAG4AdABBAG0AYgBpAGUAbgB0ACwAIAB3AG8AcgBsAGQAUABvAHMAKQA7AA==,output:2,fname:ShadeSH,width:247,height:132,input:2,input:2,input:2,input_1_label:worldNormal,input_2_label:currentAmbient,input_3_label:worldPos|A-2043-OUT,B-5227-RGB,C-3894-XYZ;n:type:ShaderForge.SFN_FragmentPosition,id:3894,x:31672,y:33604,varname:node_3894,prsc:2;n:type:ShaderForge.SFN_ViewVector,id:2248,x:31466,y:33332,varname:node_2248,prsc:2;n:type:ShaderForge.SFN_Negate,id:2043,x:31672,y:33332,varname:node_2043,prsc:2|IN-2248-OUT;n:type:ShaderForge.SFN_Slider,id:4040,x:31916,y:33646,ptovrint:False,ptlb:Indirect Factor,ptin:_IndirectFactor,varname:node_4040,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.6,max:1;n:type:ShaderForge.SFN_Multiply,id:7815,x:32240,y:33447,varname:node_7815,prsc:2|A-7558-OUT,B-4040-OUT;n:type:ShaderForge.SFN_RemapRange,id:2381,x:33378,y:33630,varname:node_2381,prsc:2,frmn:-1,frmx:1,tomn:0,tomx:1;n:type:ShaderForge.SFN_Multiply,id:6216,x:32235,y:33153,varname:node_6216,prsc:2|A-2104-RGB,B-9989-OUT,C-9989-OUT,D-2158-OUT;n:type:ShaderForge.SFN_Slider,id:2158,x:31892,y:33072,ptovrint:False,ptlb:Direct Intensy,ptin:_DirectIntensy,varname:node_2158,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:10;proporder:6074-797-4040-2158;pass:END;sub:END;*/

Shader "Shader Forge/ParticleInLight" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _IndirectFactor ("Indirect Factor", Range(0, 1)) = 0.6
        _DirectIntensy ("Direct Intensy", Range(0, 10)) = 1
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
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            float3 ShadeSH( float3 worldNormal , float3 currentAmbient , float3 worldPos ){
            return ShadeSHPerPixel(worldNormal, currentAmbient, worldPos);
            }
            
            uniform float _IndirectFactor;
            uniform float _DirectIntensy;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(2)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 finalColor = ((_MainTex_var.rgb*i.vertexColor.rgb*_TintColor.rgb*2.0)*((_LightColor0.rgb*attenuation*attenuation*_DirectIntensy)+(ShadeSH( (-1*viewDirection) , UNITY_LIGHTMODEL_AMBIENT.rgb , i.posWorld.rgb )*_IndirectFactor)));
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, finalRGBA, fixed4(0.5,0.5,0.5,1));
                return finalRGBA;
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
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            float3 ShadeSH( float3 worldNormal , float3 currentAmbient , float3 worldPos ){
            return ShadeSHPerPixel(worldNormal, currentAmbient, worldPos);
            }
            
            uniform float _IndirectFactor;
            uniform float _DirectIntensy;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float4 vertexColor : COLOR;
                LIGHTING_COORDS(2,3)
                UNITY_FOG_COORDS(4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 finalColor = ((_MainTex_var.rgb*i.vertexColor.rgb*_TintColor.rgb*2.0)*((_LightColor0.rgb*attenuation*attenuation*_DirectIntensy)+(ShadeSH( (-1*viewDirection) , UNITY_LIGHTMODEL_AMBIENT.rgb , i.posWorld.rgb )*_IndirectFactor)));
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, finalRGBA, fixed4(0.5,0.5,0.5,1));
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
