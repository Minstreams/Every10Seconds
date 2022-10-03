using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("little Components/ParticleCollisionUnityEvent")]
[RequireComponent(typeof(ParticleSystem))]
public class ParticleCollisionUnityEvent : MonoBehaviour
{
    private ParticleSystem part;
    private void Awake()
    {
        part = GetComponent<ParticleSystem>();
    }

    public FloatEvent e;
    public FloatEvent eRelativePosition;
    public float minThreadhold = 1;
    public bool mode2D = false;

    private List<ParticleCollisionEvent> collisionEvents = new List<ParticleCollisionEvent>();
    private void OnParticleCollision(GameObject other)
    {
        int numCollisionEvents = part.GetCollisionEvents(other, collisionEvents);

        Rigidbody rb = other.GetComponent<Rigidbody>();

        float mag = 0;
        if (mode2D)
            for (int i = 0; i < numCollisionEvents; i++)
            {
                float t = ((Vector2)collisionEvents[i].velocity).magnitude;
                if (t > mag) mag = t;
            }
        else
            for (int i = 0; i < numCollisionEvents; i++)
            {
                float t = collisionEvents[i].velocity.magnitude;
                if (t > mag) mag = t;
            }

        if (mag >= minThreadhold)
        {
            e?.Invoke(mag);
            eRelativePosition?.Invoke(collisionEvents[0].intersection.x - transform.position.x);
        }
    }
}
