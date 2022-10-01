using IceEngine;
using UnityEngine;

namespace Ice
{
    public sealed class Gameplay : IceEngine.Framework.IceSystem<IceEngine.Internal.SettingGameplay>
    {
        #region Events
        static void OnLevelStart()
        {
            var sp = Object.FindObjectOfType<SpawnPoint>();
            var pos = sp != null ? sp.transform.position : Vector3.zero;
            Player.SpawnAt(pos);

            UIMgr.ShowNotification("Level Start");
            UIMgr.SetBattleUI(true);
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
                field = Object.FindObjectOfType<T>();
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