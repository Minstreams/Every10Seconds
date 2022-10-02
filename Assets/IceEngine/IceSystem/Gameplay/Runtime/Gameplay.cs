using IceEngine;
using System;
using UnityEngine;
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
    }
}