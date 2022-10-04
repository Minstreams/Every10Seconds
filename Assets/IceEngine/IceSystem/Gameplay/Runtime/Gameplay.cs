﻿using IceEngine;
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
            if (field == null)
            {
                field = Obj.FindObjectOfType<T>();
                if (field == null)
                {
                    field = GameObject.Instantiate(prefab).GetComponent<T>();
                }
            }
            return field;
        }
        #endregion

        public static Player Player => GetGlobalComponent(ref _player, Setting.playerPrefab); static Player _player;
        public static CameraMgr CamMgr => GetGlobalComponent(ref _camMgr, Setting.cameraMgrPrefab); static CameraMgr _camMgr;
        public static UICanvasManager UIMgr => GetGlobalComponent(ref _uiMgr, Setting.uiCanvasManagerPrefab); static UICanvasManager _uiMgr;


        #region Dialog
        public static string currentNPC = null;
        public static Dialog curDialog;
        public static void StartDialog(Dialog dialog, string npcName)
        {
            UIMgr.SetDialogNPC(currentNPC = npcName);
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
        #endregion

        #region Save Data
        public static string SavePath => "save.bts";
        public static PlayerData Data { get; set; }
        public static void SaveData()
        {
            Save.Binary.SaveToFile(Data, SavePath);
        }
        public static void LoadData()
        {
            try
            {
                Data = Save.Binary.LoadFromFile(SavePath) as PlayerData;
            }
            catch
            {
                Data = new PlayerData();
            }
        }
        static void Awake()
        {
            LoadData();
        }

        [IcePacket]
        public sealed class PlayerData
        {
            public int coin;    // 打敌人获取，用于各种增幅
            public float hpBonus;
            public int mainWeaponMagBonus;
            public bool foundFlashLight;
        }
        #endregion
    }
}

[Serializable]
public class Dialog
{
    public Condition condition = new();
    public List<DialogBlock> blockList = new();
}
[Serializable]
public class DialogBlock
{
    public string content;
    public List<DialogChoice> dialogChoices = new();
}
[Serializable]
public class DialogChoice
{
    public string content;
    public int nextId;
    public UnityEvent action;
}

[Serializable]
public class Condition
{
    public bool alwaysTrue;
    public bool IsConditionMeet()
    {
        if (alwaysTrue) return true;
        return false;
    }
}

[System.Serializable]
public class FloatEvent : UnityEngine.Events.UnityEvent<float> { }