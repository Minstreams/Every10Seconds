using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 用于使用鼠标指定选中目标
/// </summary>
public class CursorPointer : MonoBehaviour {
    /// <summary>
    /// 记录鼠标所指位置
    /// </summary>
    private RaycastHit raycastHit;
    /// <summary>
    /// 选中位置
    /// </summary>
    [HideInInspector]
    public Vector3 point;

    [Header("瞄准平滑比率"), SerializeField, Range(0.001f, 1)]
    private float raycastPointMoveRate = 0.2f;
    [SerializeField]
    private LayerMask inputRayLayerMask;

    private void Update()
    {
        if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out raycastHit, 100, inputRayLayerMask.value))
        {
            point += raycastPointMoveRate * (raycastHit.point - point);
        }
    }
}
