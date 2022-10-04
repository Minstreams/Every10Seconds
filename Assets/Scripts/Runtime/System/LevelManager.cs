using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using static Ice.Gameplay;

namespace IceEngine
{
    /// <summary>
    /// 关内Manager
    /// </summary>
    public class LevelManager : MonoBehaviour
    {
        public Player Player => Ice.Gameplay.Player;

        public Light sun;
        public AnimationCurve intensityCurve;

        void Awake()
        {
            CurLevel = this;
        }
        void Start()
        {
            // 初始化战斗UI
            UIMgr.SetBattleUI(true);

            // 玩家生成
            var sp = FindObjectOfType<SpawnPoint>();
            var pos = sp != null ? sp.transform.position : Vector3.zero;
            Player.SpawnAt(pos);
            Player.SwitchToWeaponBasic();

            StartCoroutine(RunInLevel());
        }
        IEnumerator RunInLevel()
        {
            // Day
            CurTime = 0;
            while (true)
            {
                onMorning?.Invoke();
                isMorning = true;
                while (CurTime < 10)
                {
                    CurTime += Time.deltaTime;
                    var t = CurTime * 0.1f;
                    sun.transform.rotation = Quaternion.Euler(t * 180, 0, 0);
                    sun.intensity = intensityCurve.Evaluate(t);
                    yield return 0;
                }

                onEvening?.Invoke();
                isMorning = false;
                while (CurTime < 20)
                {
                    CurTime += Time.deltaTime;
                    var t = CurTime * 0.1f;
                    sun.transform.rotation = Quaternion.Euler(t * 180, 0, 0);
                    yield return 0;
                }
                CurTime -= 20;
            }
        }
    }
}
