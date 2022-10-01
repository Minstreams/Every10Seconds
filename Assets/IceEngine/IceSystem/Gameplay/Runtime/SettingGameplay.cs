using UnityEngine;

namespace IceEngine.Internal
{
    [IceSettingPath("IceEngine/IceSystem/Gameplay")]
    public class SettingGameplay : Framework.IceSetting<SettingGameplay>
    {
        public GameObject spawnPointPrefab;
        public GameObject uiCanvasManagerPrefab;
        public GameObject playerPrefab;
    }
}