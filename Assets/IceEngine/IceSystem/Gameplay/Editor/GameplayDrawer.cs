using IceEngine;
using UnityEditor;
using UnityEngine;
using static IceEditor.IceGUI;
using static IceEditor.IceGUIAuto;
using Sys = Ice.Gameplay;
using SysSetting = IceEngine.Internal.SettingGameplay;

namespace IceEditor.Internal
{
    internal sealed class GameplayDrawer : Framework.IceSystemDrawer<Sys, SysSetting>
    {
        public override void OnToolBoxGUI()
        {
            if (Button("开始编辑场景"))
            {
                Selection.activeObject = Setting.spawnPointPrefab;
            }
        }
        [HierarchyItemGUICallback]
        static void ItemGUI(CameraMgr mgr, Rect selectionRect)
        {
            if (UnityEditor.EditorApplication.isPlaying) return;
            if (IceButton("对齐"))
            {
                mgr.AlignCamera();
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
    }
}