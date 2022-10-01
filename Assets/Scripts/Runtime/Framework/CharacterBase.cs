using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    /// <summary>
    /// 可移动的敌人和玩家，实现武器&移动&Buff接口
    /// </summary>
    public abstract class CharacterBase : MonoBehaviour
    {
        #region Weapon
        public abstract Weapon CurrentWeapon { get; }
        #endregion

        #region Buff
        public List<Buff> buffList = new();
        #endregion

        #region Movement
        const float rotateAcFactor = 0.2f;  //加速度转换常量
        Animator anim;
        bool flip = false;  //转身
        float rotateParameter = 0;  //动画参数
        float rotateAc = 0;  //加速度

        [Header("移动参数")]
        public Transform focusPoint;
        [Label("旋转速率"), Range(0.001f, 1)] public float rotateRate = 0.07f;
        [Label("转身阈值"), Range(0.001f, 1)] public float flipThreshold = 0.1f;
        [Label("动画参数归零比率"), Range(0.001f, 1)] public float rotateDyingRate = 0.96f;
        #endregion

        protected virtual void Awake()
        {
            anim = GetComponent<Animator>();
        }
        protected void Move(Vector3 forward, float speed, Vector3 sightDir)
        {
            float sightAngle = Vector3.SignedAngle(transform.forward, sightDir, Vector3.up);  //视线转角

            //反转
            float angleOffset = CurrentWeapon.aimAngleOffset;
            float tempDot = Vector3.Dot(sightDir, Quaternion.AngleAxis(angleOffset, Vector3.up) * forward);
            if (flip != tempDot < 0)
            {
                //若过阈值则转身
                flip = tempDot < -flipThreshold;
            }

            float angle = sightAngle;   //转向角

            if (speed != 0)
            {
                //计算angle
                Vector3 targetFaceForward = flip ? -forward : forward;
                angle = Vector3.SignedAngle(transform.forward, targetFaceForward, Vector3.up);
                if ((
                (sightAngle > angleOffset + 90 && sightAngle < angleOffset + 180) ||
                (sightAngle < angleOffset - 180 && sightAngle > angleOffset - 270)
                ) && angle < -90) angle += 360;
                if ((
                (sightAngle > angleOffset - 180 && sightAngle < angleOffset - 90) ||
                (sightAngle < angleOffset + 180 && sightAngle > angleOffset + 270)
                ) && angle > 90) angle -= 360;
                if (flip) speed = -speed;
            }

            //播放转身动画
            rotateAc = Mathf.Sin(angle * Mathf.PI / 360.0f) * rotateAcFactor;
            rotateParameter += rotateAc;
            rotateParameter *= rotateDyingRate;
            anim.SetFloat("turn", rotateParameter > 0 ? Mathf.Clamp01(rotateParameter - 0.3f) : -Mathf.Clamp01(-0.3f - rotateParameter));
            transform.Rotate(Vector3.up, angle * (1 - Mathf.Pow(1 - rotateRate, Time.deltaTime)));

            //播放行走动画
            anim.SetFloat("speed", speed);

            //Debug Draw
            //Debug.DrawLine(transform.position + Vector3.up * 0.6f, transform.position + Vector3.up * 0.6f + forward * 5, Color.yellow); //目标前进方向
            //Debug.DrawLine(transform.position + Vector3.up * 0.6f, transform.position + Vector3.up * 0.6f + transform.forward * 2, Color.white, 0.1f);  //实际面朝方向
        }

        #region IK (可删)
        public virtual Vector3 TargetLook => Vector3.zero;
        public virtual float WeightLook => 1;
        public virtual Vector3 TargetLeftHand => TargetLook;
        public virtual Quaternion RotLeftHand => Quaternion.LookRotation(TargetLeftHand - transform.position) * Quaternion.AngleAxis(-90, Vector3.forward);
        public float WeightLeftHandPos => CurrentWeapon.ikLeftHand;
        public virtual float WeightLeftHandRot => CurrentWeapon.ikLeftHand;
        public virtual Vector3 TargetRightHand => TargetLook;
        public virtual Quaternion RotRightHand => Quaternion.LookRotation(TargetRightHand - transform.position) * Quaternion.AngleAxis(-90, Vector3.forward);
        public float WeightRightHandPos => CurrentWeapon.ikRightHand;
        public float WeightRightHandRot => CurrentWeapon.ikRightHand;

        void OnAnimatorIK(int layerIndex)
        {
            //视线位置
            anim.SetLookAtWeight(WeightLook, 0.5f, 0, 0, 1);
            anim.SetLookAtPosition(TargetLook);

            //左手位置
            anim.SetIKPositionWeight(AvatarIKGoal.LeftHand, WeightLeftHandPos);
            anim.SetIKRotationWeight(AvatarIKGoal.LeftHand, WeightLeftHandRot);
            anim.SetIKPosition(AvatarIKGoal.LeftHand, TargetLeftHand);
            anim.SetIKRotation(AvatarIKGoal.LeftHand, RotLeftHand);

            //右手位置
            anim.SetIKPositionWeight(AvatarIKGoal.RightHand, WeightRightHandPos);
            anim.SetIKRotationWeight(AvatarIKGoal.RightHand, WeightRightHandRot);
            anim.SetIKPosition(AvatarIKGoal.RightHand, TargetRightHand);
            anim.SetIKRotation(AvatarIKGoal.RightHand, RotRightHand);
        }
        #endregion
    }
}
