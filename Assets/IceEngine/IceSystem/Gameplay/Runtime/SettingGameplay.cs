using UnityEngine;

namespace IceEngine.Internal
{
    public class SettingGameplay : Framework.IceSetting<SettingGameplay>
    {
        [Group]
        public GameObject spawnPointPrefab;
        public GameObject uiCanvasManagerPrefab;
        public GameObject playerPrefab;

        public string coinMark = "✪";
        public float enemyWeight = 15;

        [Group]
        public LayerMask maskPlayerAim;

        public int LayerPlayer => _layerPlayer ??= LayerMask.NameToLayer("Player"); int? _layerPlayer;
        public int LayerEnemy => _layerEnmey ??= LayerMask.NameToLayer("Enemy"); int? _layerEnmey;
        public int LayerEnemyAimBox => _layerEnmeyAimBox ??= LayerMask.NameToLayer("EnemyAimBox"); int? _layerEnmeyAimBox;
        public int LayerGround => _layerGround ??= LayerMask.NameToLayer("Ground"); int? _layerGround;
        public int LayerPickable => _layerPickable ??= LayerMask.NameToLayer("Pickable"); int? _layerPickable;
        public int LayerPickableSelected => _layerPickableSelected ??= LayerMask.NameToLayer("PickableSelected"); int? _layerPickableSelected;
        public int LayerWall => _layerWall ??= LayerMask.NameToLayer("Wall"); int? _layerWall;
    }
}