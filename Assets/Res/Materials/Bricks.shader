Shader "Ice/BaseBricks"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _Tint("Tint", Color) = (1, 1, 1, 1)
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _MetallicColor("MetallicColor", Color) = (0, 0, 0, 0)
        _EmissionTarget("EmissionTarget", Color) = (0, 0, 0, 0)
        [HDR]_EmissionColor("EmissionColor", Color) = (1, 1, 1, 1)
        _ThresRange("ThresRange", Range(0.01, 1)) = 0.1
        _Angle("Angle", Range(0.01, 1)) = 0.1
        _AlphaThres("AlphaThres", Range(0, 1)) = 0.5
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float4(float4 A, float4 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float _Property_cf79794094864092b120d38d85d40d00_Out_0 = _ThresRange;
            float4 _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0 = _EmissionTarget;
            float _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2);
            float _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2, _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3);
            float4 _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            float4 _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2;
            Unity_Multiply_float4_float4((_Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3.xxxx), _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0, _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2);
            float4 _Property_d3b2fe846f5f4cfe814781fd2536b1d0_Out_0 = _MetallicColor;
            float _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_d3b2fe846f5f4cfe814781fd2536b1d0_Out_0, _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2);
            float _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2, _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3);
            float _Property_79b270d095384a22901824d08c7db93e_Out_0 = _Smoothness;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2.xyz);
            surface.Metallic = _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3;
            surface.Smoothness = _Property_79b270d095384a22901824d08c7db93e_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float4(float4 A, float4 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float _Property_cf79794094864092b120d38d85d40d00_Out_0 = _ThresRange;
            float4 _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0 = _EmissionTarget;
            float _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2);
            float _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2, _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3);
            float4 _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            float4 _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2;
            Unity_Multiply_float4_float4((_Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3.xxxx), _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0, _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2);
            float4 _Property_d3b2fe846f5f4cfe814781fd2536b1d0_Out_0 = _MetallicColor;
            float _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_d3b2fe846f5f4cfe814781fd2536b1d0_Out_0, _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2);
            float _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2, _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3);
            float _Property_79b270d095384a22901824d08c7db93e_Out_0 = _Smoothness;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2.xyz);
            surface.Metallic = _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3;
            surface.Smoothness = _Property_79b270d095384a22901824d08c7db93e_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float4(float4 A, float4 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float _Property_cf79794094864092b120d38d85d40d00_Out_0 = _ThresRange;
            float4 _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0 = _EmissionTarget;
            float _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2);
            float _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2, _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3);
            float4 _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            float4 _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2;
            Unity_Multiply_float4_float4((_Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3.xxxx), _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0, _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2);
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.Emission = (_Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2.xyz);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float4(float4 A, float4 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float _Property_cf79794094864092b120d38d85d40d00_Out_0 = _ThresRange;
            float4 _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0 = _EmissionTarget;
            float _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2);
            float _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2, _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3);
            float4 _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            float4 _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2;
            Unity_Multiply_float4_float4((_Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3.xxxx), _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0, _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2);
            float4 _Property_d3b2fe846f5f4cfe814781fd2536b1d0_Out_0 = _MetallicColor;
            float _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_d3b2fe846f5f4cfe814781fd2536b1d0_Out_0, _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2);
            float _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_2ab9f4ac5c5747a4b9e29f8098965605_Out_2, _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3);
            float _Property_79b270d095384a22901824d08c7db93e_Out_0 = _Smoothness;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2.xyz);
            surface.Metallic = _Smoothstep_e4b7188dd5df419992ef6bb0174e7bbd_Out_3;
            surface.Smoothness = _Property_79b270d095384a22901824d08c7db93e_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float4(float4 A, float4 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float _Property_cf79794094864092b120d38d85d40d00_Out_0 = _ThresRange;
            float4 _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0 = _EmissionTarget;
            float _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2;
            Unity_Distance_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_9387fb46472b4af8857a6883a5dcbd5b_Out_0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2);
            float _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3;
            Unity_Smoothstep_float(_Property_cf79794094864092b120d38d85d40d00_Out_0, 0, _Distance_842c21daef3a4e44bc9110b4a28c88c3_Out_2, _Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3);
            float4 _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            float4 _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2;
            Unity_Multiply_float4_float4((_Smoothstep_abe78e2c79014c9297480528aa70b74d_Out_3.xxxx), _Property_c31c5a28df404a59b931ea22433b5bcb_Out_0, _Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2);
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.Emission = (_Multiply_d9abb61a15cd42a2a94d5d85f951d035_Out_2.xyz);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Tint;
        float _Smoothness;
        float4 _MetallicColor;
        float4 _EmissionTarget;
        float4 _EmissionColor;
        float _ThresRange;
        float _Angle;
        float _AlphaThres;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float3 _PlayerPosition;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }
        
        
        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }
        
        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);
        
            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);
        
                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_54edf920cfd4403e87dbcf898226a79e_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54edf920cfd4403e87dbcf898226a79e_Out_0.tex, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.samplerstate, _Property_54edf920cfd4403e87dbcf898226a79e_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_R_4 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.r;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_G_5 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.g;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_B_6 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.b;
            float _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_A_7 = _SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0.a;
            float4 _Property_b3c882408b524899961383d94d4792de_Out_0 = _Tint;
            float4 _Multiply_76c4c3ac891843579b468e6630202089_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_e14d137d455b4e8294a1726b432c5e80_RGBA_0, _Property_b3c882408b524899961383d94d4792de_Out_0, _Multiply_76c4c3ac891843579b468e6630202089_Out_2);
            float3 _Property_daa803b325ef4134a570b64a765bbab2_Out_0 = _PlayerPosition;
            float _Split_3a498c979e11402f989e4a9ec4825cb0_R_1 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[0];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_G_2 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[1];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_B_3 = _Property_daa803b325ef4134a570b64a765bbab2_Out_0[2];
            float _Split_3a498c979e11402f989e4a9ec4825cb0_A_4 = 0;
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_R_1 = IN.WorldSpacePosition[0];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2 = IN.WorldSpacePosition[1];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_B_3 = IN.WorldSpacePosition[2];
            float _Split_4c00a68f1526430aa58b6c0c37c1f41d_A_4 = 0;
            float _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2;
            Unity_Subtract_float(_Split_3a498c979e11402f989e4a9ec4825cb0_G_2, _Split_4c00a68f1526430aa58b6c0c37c1f41d_G_2, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2);
            float _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3;
            Unity_Smoothstep_float(-1, 0, _Subtract_4a6c986d8c61484e818d8d1ce3106f77_Out_2, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3);
            float _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2;
            Unity_Maximum_float(0, _Smoothstep_5c335d40807d4503b4f9dd5a6b477a83_Out_3, _Maximum_b580ec50a2994628ae844c3944e458d4_Out_2);
            float _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0 = _Angle;
            float _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2;
            Unity_Add_float(-1, _Property_d02a3acc58fa4172b98e14651ae8e291_Out_0, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2);
            float3 _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_daa803b325ef4134a570b64a765bbab2_Out_0, _Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2);
            float3 _Normalize_2787d55292c94ce59122ee225bc75941_Out_1;
            Unity_Normalize_float3(_Subtract_d7b78921460c4788a8ae65d6eaa56fd1_Out_2, _Normalize_2787d55292c94ce59122ee225bc75941_Out_1);
            float _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2;
            Unity_DotProduct_float3((-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz)), _Normalize_2787d55292c94ce59122ee225bc75941_Out_1, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2);
            float _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3;
            Unity_Smoothstep_float(-1, _Add_4796635b0a384e6b87417b4da87f1f2d_Out_2, _DotProduct_7cf21b3bbe594d70aa210ef937e3e042_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3);
            float _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2;
            Unity_Maximum_float(_Maximum_b580ec50a2994628ae844c3944e458d4_Out_2, _Smoothstep_b1ee34ece74b4304aba61a035e4443dc_Out_3, _Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2);
            float4 _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w * 2 - 1, 0, 0);
            float _Split_a12850ea3991470493cfe616cc4e11c2_R_1 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[0];
            float _Split_a12850ea3991470493cfe616cc4e11c2_G_2 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[1];
            float _Split_a12850ea3991470493cfe616cc4e11c2_B_3 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[2];
            float _Split_a12850ea3991470493cfe616cc4e11c2_A_4 = _ScreenPosition_20f1ef67a59d4f84aa55b2f7804cf6bf_Out_0[3];
            float _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_R_1, _ScreenParams.x, _Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2);
            float _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2;
            Unity_Multiply_float_float(_Split_a12850ea3991470493cfe616cc4e11c2_G_2, _ScreenParams.y, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Vector2_67aadaec5f514f70806522b7da838ede_Out_0 = float2(_Multiply_e3432360e2374543a58b5f1992a4bc8b_Out_2, _Multiply_0bfca9894e7f410187f37e69675d38a1_Out_2);
            float2 _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2;
            Unity_Divide_float2(_Vector2_67aadaec5f514f70806522b7da838ede_Out_0, (_ScreenParams.y.xx), _Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2);
            float _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1;
            Unity_Length_float2(_Divide_b10e6abd863c42ec8db4b219dc2e6918_Out_2, _Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1);
            float _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2;
            Unity_Divide_float(_Length_1e2d7c4d3515486c9886bcce8b298e07_Out_1, 3, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2);
            float _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2;
            Unity_Maximum_float(_Maximum_72bea01eca1842d7b17eb894f1f7e2ba_Out_2, _Divide_0480a0dc3244473baddea82c3bf3964f_Out_2, _Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2);
            float _Property_b23f60e383ae43738944a6486f17fd76_Out_0 = _AlphaThres;
            float _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1;
            Unity_OneMinus_float(_Property_b23f60e383ae43738944a6486f17fd76_Out_0, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1);
            float _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2;
            Unity_Multiply_float_float(0.6, _OneMinus_eac04b2dc7e049f2be711606107dad32_Out_1, _Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2);
            float _Split_606a749a0f674981be3816f5579b1f15_R_1 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[0];
            float _Split_606a749a0f674981be3816f5579b1f15_G_2 = _Vector2_67aadaec5f514f70806522b7da838ede_Out_0[1];
            float _Split_606a749a0f674981be3816f5579b1f15_B_3 = 0;
            float _Split_606a749a0f674981be3816f5579b1f15_A_4 = 0;
            float _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1;
            Unity_Sine_float(_Split_606a749a0f674981be3816f5579b1f15_R_1, _Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1);
            float2 _Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0 = float2(_Sine_8107ec90636e4ebd8a04f04783ba6e22_Out_1, _Split_606a749a0f674981be3816f5579b1f15_G_2);
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3;
            float _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4;
            Unity_Voronoi_float(_Vector2_c238fd0e4fdb44bfb865943a38ea74ef_Out_0, IN.TimeParameters.x, 0.1, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Cells_4);
            float _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2;
            Unity_Multiply_float_float(_Multiply_703d44d1005f4be4a9e44760af25f5a1_Out_2, _Voronoi_cdc358d2d0bc4a5aa17eefa1ca099801_Out_3, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2);
            float _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            Unity_Subtract_float(_Maximum_4930cb9dcc6446aca6341badaaec9c44_Out_2, _Multiply_d3319d5f2e1d4de990d291f3e141e4c3_Out_2, _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2);
            surface.BaseColor = (_Multiply_76c4c3ac891843579b468e6630202089_Out_2.xyz);
            surface.Alpha = _Subtract_e051dcd5c2804b429556d1f771a50fb9_Out_2;
            surface.AlphaClipThreshold = _Property_b23f60e383ae43738944a6486f17fd76_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}