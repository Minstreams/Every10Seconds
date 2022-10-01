using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MyScriptableObject
{
    [CreateAssetMenu(fileName = "Ammo", menuName = "My Scriptable Object/Ammo Material")]
    public class AmmoMaterial : ScriptableObject
    {
        //字段-----------------------------------
        /// <summary>
        /// 每颗子弹重量，单位克
        /// </summary>
        [Header("Mass(gram)"), Tooltip("每颗子弹重量，单位克"), SerializeField]
        private float mass = 8;
        /// <summary>
        /// 子弹出膛初速度，单位米/秒
        /// </summary>
        [Header("Initial Velocity(meter per second)"), Tooltip("子弹出膛初速度，单位米/秒"), SerializeField]
        private float velocity = 360;
        /// <summary>
        /// 开枪声音
        /// </summary>
        [Tooltip("开枪声音"), SerializeField]
        private AudioClip gunShotAudio;


        //属性-----------------------------------
        /// <summary>
        /// 单位 千克
        /// </summary>
        public float Mass
        {
            get
            {
                return mass * 0.001f;
            }
        }
        public float Velocity
        {
            get
            {
                return velocity;
            }
        }
        public AudioClip GunShotAudio
        {
            get
            {
                return gunShotAudio;
            }
        }


        //方法-----------------------------------
        /// <summary>
        /// 获取动量
        /// </summary>
        /// <returns></returns>
        public float GetMomentum()
        {
            return mass * 0.001f * velocity;
        }
    }
}
