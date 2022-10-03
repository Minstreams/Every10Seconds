using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("little Components/DynamicAudioSource")]
[RequireComponent(typeof(AudioSource))]
public class DynamicAudioSource : MonoBehaviour
{
    AudioSource aus;
    private void Awake()
    {
        aus = GetComponent<AudioSource>();
    }

    public Vector2 inputRange = Vector2.up;
    public Vector2 pitchRange = Vector2.one;
    public Vector2 volumeRange = Vector2.up;

    public void Play(float input)
    {
        float t = Mathf.InverseLerp(inputRange.x, inputRange.y, input);
        aus.pitch = Mathf.Lerp(pitchRange.x, pitchRange.y, t);
        aus.volume = Mathf.Lerp(volumeRange.x, volumeRange.y, t);
        aus.Play();
    }

}
