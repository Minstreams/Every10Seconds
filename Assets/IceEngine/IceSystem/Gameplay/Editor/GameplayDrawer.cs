using IceEngine;
using UnityEditor;
using UnityEngine;
using static IceEditor.IceGUI;
using static IceEditor.IceGUIAuto;
using Sys = Ice.Gameplay;
using SysSetting = IceEngine.Internal.SettingGameplay;

namespace IceEditor.Internal
{
    public sealed class GameplayDrawer : Framework.IceSystemDrawer<Sys, SysSetting>
    {
        public override void OnToolBoxGUI()
        {
            if (Button("开始编辑场景"))
            {
                Selection.activeObject = Setting.spawnPointPrefab;
            }
        }
        [HierarchyItemGUICallback]
        static void ItemGUI(SpawnPoint sp, Rect selectionRect)
        {
            if (sp.valid)
            {
                if (IceButton("放于地面"))
                {
                    sp.PutOnGround();
                }
            }
            else if (E.type == EventType.Repaint)
            {
                UnityEngine.Object.DestroyImmediate(sp.gameObject);
            }
        }
        [HierarchyItemGUICallback]
        static void ItemGUI(EnemySpawnPoint sp, Rect selectionRect)
        {
            if (IceButton("放于地面"))
            {
                sp.PutOnGround();
            }
        }

        [MenuItem("Assets/准备模型")]
        static void PrepareModel()
        {
            foreach (var go in Selection.gameObjects)
            {
                PrepareModel(go);
                EditorUtility.SetDirty(go);
            }
        }
        [MenuItem("Assets/刷ShadowCaster")]
        static void PrepareModelShadow()
        {
            foreach (var go in Selection.gameObjects)
            {
                var model = go.transform.GetChild(0).gameObject;
                model.GetComponent<Renderer>().staticShadowCaster = true;
                EditorUtility.SetDirty(go);
            }
        }

        public static void PrepareModel(GameObject go)
        {
            if (go.GetComponent<SceneProp>() != null) return;
            // Model
            var model = go.transform.GetChild(0).gameObject;
            // Layer
            model.layer = go.layer = LayerMask.NameToLayer("Ground");
            // Static
            model.isStatic = go.isStatic = true;
            // Component
            go.AddComponent<SceneProp>().type = SceneProp.PropType.Ground;
            // Collider
            model.AddComponent<BoxCollider>();
            // Material
            model.GetComponent<Renderer>().staticShadowCaster = true;
            //model.GetComponent<Renderer>().sharedMaterial.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
        }
    }
}