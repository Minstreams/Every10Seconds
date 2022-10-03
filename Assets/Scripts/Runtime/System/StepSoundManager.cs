using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StepSoundManager : MonoBehaviour
{
    public CharacterController cc;
    public AudioSource stepSource;

    public Vector2 volumeRange;
    public Vector2 pitchRange;
    public float maxVelocity = 3.0f;

    public void Step()
    {
        if (stepSource == null) return;

        float v = cc.velocity.magnitude;
        float t = Mathf.Min(1.0f, v / maxVelocity);

        stepSource.pitch = Mathf.Lerp(pitchRange.y, pitchRange.x, t) * Time.timeScale;
        stepSource.volume = Mathf.Lerp(volumeRange.x, volumeRange.y, t);
        stepSource.Play();
    }
}
