using IceEngine;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Obj = UnityEngine.Object;

namespace Ice
{
    public sealed class Gameplay : IceEngine.Framework.IceSystem<IceEngine.Internal.SettingGameplay>
    {
        public static LevelManager CurLevel { get; set; }
        public static float CurTime { get; set; }

        #region Events
        public static bool isMorning;
        public static Action onMorning;
        public static Action onEvening;
        #endregion

        #region Utility
        static T GetGlobalComponent<T>(ref T field, GameObject prefab) where T : MonoBehaviour
        {
#if UNITY_EDITOR
            if (!UnityEditor.EditorApplication.isPlaying) return null;
#endif
            if (field is null)
            {
                field = Obj.FindObjectOfType<T>();
                if (field is null)
                {
                    field = GameObject.Instantiate(prefab).GetComponent<T>();
                }
            }
            return field;
        }
        #endregion

        public static Player Player => GetGlobalComponent(ref _player, Setting.playerPrefab); static Player _player;
        public static CameraMgr CamMgr { get; set; }
        public static UICanvasManager UIMgr => GetGlobalComponent(ref _uiMgr, Setting.uiCanvasManagerPrefab); static UICanvasManager _uiMgr;


        #region Dialog & NPC
        public static NPC currentNPC = null;
        public static Dialog curDialog;
        public static void StartDialog(Dialog dialog, NPC npc)
        {
            if (dialog == null) return;
            currentNPC = npc;
            UIMgr.SetDialogNPC(dialog.npcName);
            curDialog = dialog;
            UIMgr.DisplayDialogBlock(dialog.blockList[0]);
        }
        public static void ToDialogBlock(int i)
        {
            if (i >= 0)
            {
                UIMgr.DisplayDialogBlock(curDialog.blockList[i]);
            }
            else CloseDialog();
        }
        public static void CloseDialog()
        {
            currentNPC = null;
            curDialog = null;
            UIMgr.CloseDialog();
        }
        public static void DoNPCAction(string action)
        {
            if (action.IsNullOrEmpty()) return;
            // TODO
        }
        #endregion

        #region Save Data
        public static string SavePath => "save.bts";
        public static PlayerData Data { get; set; }
        public static void SaveData()
        {
            // 序列化
            Data.unlockedList.Clear();
            Data.unlockedList.AddRange(Data.unlockedSet);
            Save.Binary.SaveToFile(Data, SavePath);
            UIMgr.ShowNotification("Progress Saved.");
        }
        public static void LoadData()
        {
            try
            {
                Data = Save.Binary.LoadFromFile(SavePath) as PlayerData;
                foreach (var l in Data.unlockedList)
                {
                    Data.unlockedSet.Add(l);
                }
            }
            catch
            {
                Data = new PlayerData();
            }
        }
        static void Awake()
        {
            LoadData();
            Physics.IgnoreLayerCollision(Setting.LayerGrenade, Setting.LayerPlayer);
        }

        [IcePacket]
        public sealed class PlayerData
        {
            // Status
            public int coin;    // 打敌人获取，用于各种增幅
            public float hpBonus;
            public int mainWeaponMagBonus;
            public int grenadeCountBonus;

            // Statistics   // 仅限一条命的数据，死了清空
            public int id = 1021;
            public int coinAll; // 目前获得过的所有的金币
            public int ammos;   // 发射过的子弹数
            public int enemiesBeaten;   // 打败的敌人
            public int days;    // 本条命，过的天数

            // Collections
            [NonSerialized] public HashSet<string> unlockedSet = new();
            public List<string> unlockedList = new();
            public bool IsUnlocked(string name) => unlockedSet.Contains(name);
        }
        #endregion
    }
}


[System.Serializable]
public class SimpleEvent : UnityEvent { }
[System.Serializable]
public class IntEvent : UnityEvent<int> { }
[System.Serializable]
public class FloatEvent : UnityEvent<float> { }
[System.Serializable]
public class Vec2Event : UnityEvent<Vector2> { }
[System.Serializable]
public class Vec3Event : UnityEvent<Vector3> { }
[System.Serializable]
public class StringEvent : UnityEvent<string> { }
[System.Serializable]
public class ColorEvent : UnityEvent<Color> { }
[System.Serializable]
public class BoolEvent : UnityEvent<bool> { }