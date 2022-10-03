using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace IceEngine
{
    public class ColliderEventTrigger : MonoBehaviour
    {
        public UnityEvent onPlayerEnter;
        public UnityEvent onPlayerExit;
        void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                onPlayerEnter?.Invoke();
            }
        }
        void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                onPlayerExit?.Invoke();
            }
        }

    }
}
