using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class DroneEffectHolder : MonoBehaviour
    {
        public LineRenderer line;
        public ParticleSystem ps;

        public float time;
        public AnimationCurve lineAlphaCurve;
        public AnimationCurve lineLengthCurve;
        public AnimationCurve lineWidthCurve;
        public AnimationCurve psLifeCurve;
        public AnimationCurve psSizeCurve;
        public AnimationCurve posXCurve;
        public AnimationCurve posYCurve;
        public AnimationCurve posZCurve;

        public bool autoMode;
        public Action onPlayed;

        Vector3 position;

        void Start()
        {
            if (autoMode) Play();
        }
        void OnDestroy()
        {
            if (playRoutine != null) onPlayed?.Invoke();
        }
        void ApplyEffect(float t)
        {
            if (line != null)
            {
                var c = line.startColor;
                c.a = lineAlphaCurve.Evaluate(t);
                line.startColor = c;
                line.SetPosition(1, Vector3.down * lineLengthCurve.Evaluate(t));
                line.startWidth = lineWidthCurve.Evaluate(t);
            }

            if (ps != null)
            {
                var m = ps.main;
                m.startLifetime = psLifeCurve.Evaluate(t);
                m.startSize = psSizeCurve.Evaluate(t);
            }

            {
                transform.position = position + new Vector3(posXCurve.Evaluate(t), posYCurve.Evaluate(t), posZCurve.Evaluate(t));
            }
        }

        [Button]
        public void Play(Action callback = null)
        {
            if (!autoMode)
            {
                var pt = Ice.Gameplay.Player.transform;
                transform.position = pt.position + pt.forward + Vector3.up;
                transform.rotation = pt.rotation;
            }
            position = transform.position;
            if (callback != null) onPlayed += callback;

            StopAllCoroutines();
            playRoutine = StartCoroutine(RunPlay());
        }

        Coroutine playRoutine;
        IEnumerator RunPlay()
        {
            float t = 0;
            while (t < time)
            {
                ApplyEffect(t);
                yield return 0;
                t += Time.deltaTime;
            }
            ApplyEffect(time);
            if (autoMode) StartCoroutine(RunPlay());
            else onPlayed?.Invoke();
            playRoutine = null;
        }

    }
}
