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

        #region Events
        public static bool isMorning;
        public static Action onMorning;
        public static Action onEvening;
        public static void Escape()
        {
            UIMgr.ShowNotification("Escape");
        }
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

        #region Player
        public static Player Player => GetGlobalComponent(ref _player, Setting.playerPrefab); static Player _player;
        #endregion

        #region UI
        public static UICanvasManager UIMgr => GetGlobalComponent(ref _uiMgr, Setting.uiCanvasManagerPrefab); static UICanvasManager _uiMgr;
        #endregion

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
    }
}

[Serializable]
public class Dialog
{
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