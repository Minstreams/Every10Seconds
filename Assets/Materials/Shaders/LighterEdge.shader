// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:Particles/Additive,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:4,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33287,y:32605,varname:node_9361,prsc:2|custl-702-RGB,alpha-9198-OUT;n:type:ShaderForge.SFN_Fresnel,id:6918,x:32471,y:32997,varname:node_6918,prsc:2;n:type:ShaderForge.SFN_Color,id:702,x:32471,y:32844,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_702,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_TexCoord,id:7886,x:32471,y:33131,varname:node_7886,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:9198,x:33012,y:32996,varname:node_9198,prsc:2|A-2578-OUT,B-9978-OUT,C-578-OUT,D-324-OUT;n:type:ShaderForge.SFN_OneMinus,id:2578,x:32646,y:32996,varname:node_2578,prsc:2|IN-6918-OUT;n:type:ShaderForge.SFN_RemapRange,id:5163,x:32646,y:33131,varname:node_5163,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-7886-V;n:type:ShaderForge.SFN_Clamp01,id:9978,x:32840,y:33131,varname:node_9978,prsc:2|IN-5163-OUT;n:type:ShaderForge.SFN_Noise,id:9700,x:32646,y:33297,varname:node_9700,prsc:2|XY-7886-UVOUT;n:type:ShaderForge.SFN_ScreenPos,id:632,x:32471,y:33287,varname:node_632,prsc:2,sctp:2;n:type:ShaderForge.SFN_Slider,id:820,x:32489,y:33462,ptovrint:False,ptlb:NoiseRate,ptin:_NoiseRate,varname:node_820,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:9398,x:32840,y:33293,varname:node_9398,prsc:2|A-9700-OUT,B-820-OUT;n:type:ShaderForge.SFN_OneMinus,id:578,x:33016,y:33293,varname:node_578,prsc:2|IN-9398-OUT;n:type:ShaderForge.SFN_Desaturate,id:324,x:32646,y:32844,varname:node_324,prsc:2|COL-702-RGB;proporder:702-820;pass:END;sub:END;*/

Shader "Shader Forge/LighterEdge" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _NoiseRate ("NoiseRate", Range(0, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay"
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
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _MainColor;
            uniform float _NoiseRate;
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
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
                float3 finalColor = _MainColor.rgb;
                float2 node_9700_skew = i.uv0 + 0.2127+i.uv0.x*0.3713*i.uv0.y;
                float2 node_9700_rnd = 4.789*sin(489.123*(node_9700_skew));
                float node_9700 = frac(node_9700_rnd.x*node_9700_rnd.y*(1+node_9700_skew.x));
                return fixed4(finalColor,((1.0 - (1.0-max(0,dot(normalDirection, viewDirection))))*saturate((i.uv0.g*2.0+-1.0))*(1.0 - (node_9700*_NoiseRate))*dot(_MainColor.rgb,float3(0.3,0.59,0.11))));
            }
            ENDCG
        }
    }
    FallBack "Particles/Additive"
    CustomEditor "ShaderForgeMaterialInspector"
}
