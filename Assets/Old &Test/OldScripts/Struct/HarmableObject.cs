using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 能被子弹伤害的物体父类
/// </summary>
public abstract class HarmableObject : MonoBehaviour {
    public abstract void Harm(MyScriptableObject.AmmoMaterial ammoMaterial, RaycastHit ammoHit, Vector3 ammoDir);
}
