using UnityEngine;

namespace IceEngine.Internal
{
    public class SettingGameplay : Framework.IceSetting<SettingGameplay>
    {
        public GameObject spawnPointPrefab;
        public GameObject uiCanvasManagerPrefab;
        public GameObject playerPrefab;

        public string coinMark = "✪";
    }
}