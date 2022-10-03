using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("little Components/RemapFloatEvent")]
public class RemapFloatEvent : MonoBehaviour
{
    public Vector2 inputRange;
    public Vector2 outputRange;

    public FloatEvent e;

    public void InvokeEvent(float input)
    {
        e?.Invoke(Mathf.Lerp(outputRange.x, outputRange.y, Mathf.InverseLerp(inputRange.x, inputRange.y, input)));
    }

}
