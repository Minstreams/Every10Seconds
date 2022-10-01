using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class Weapon : MonoBehaviour
    {
        /// <summary>
        /// 瞄准的方向，影响转身判定，0为正前方，-90为正左方
        /// </summary>
        [Range(-180f, 180f)] public float aimAngleOffset = 0;
        [Range(0f, 1f)] public float ikLeftHand = 0;
        [Range(0f, 1f)] public float ikRightHand = 0;
    }
}
