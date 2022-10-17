using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IceEngine
{
    public class LightArea : MonoBehaviour
    {
        public float intensity = 1;
        HashSet<Enemy> enemies = new();
        void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Enemy"))
            {
                var e = other.GetComponentInParent<Enemy>();
                if (e != null && !enemies.Contains(e))
                {
                    Debug.Log("Enemy Enter!");
                    enemies.Add(e);
                    e.extraLight += intensity;
                }
            }
        }
        void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Enemy"))
            {
                var e = other.GetComponentInParent<Enemy>();
                if (e != null && enemies.Contains(e))
                {
                    enemies.Remove(e);
                    e.extraLight -= intensity;
                }
            }
        }

        void OnDisable()
        {
            foreach (var e in enemies)
            {
                e.extraLight -= intensity;
            }
            enemies.Clear();
        }
    }
}
