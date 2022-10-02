using IceEngine;
using System;
using UnityEngine;
using Obj = UnityEngine.Object;

namespace Ice
{
    public sealed class Gameplay : IceEngine.Framework.IceSystem<IceEngine.Internal.SettingGameplay>
    {
        #region Events
        public static Action onMorning;
        public static Action onEvening;
        static void OnLevelStart()
        {
            var sp = Obj.FindObjectOfType<SpawnPoint>();
            var pos = sp != null ? sp.transform.position : Vector3.zero;
            Player.SpawnAt(pos);

            UIMgr.ShowNotification("Level Start");
            UIMgr.SetBattleUI(true);

            Player.SwitchToWeaponBasic();

            onEvening?.Invoke();
        }
        static void OnLevelEnd()
        {
            UIMgr.SetBattleUI(false);
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