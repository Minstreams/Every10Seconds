using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class tsetNav : MonoBehaviour
{
    public Vector3 pos = Vector3.zero;
    NavMeshAgent nav;
    // Start is called before the first frame update
    void Start()
    {
        nav = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    void Update()
    {
        nav.SetDestination(pos);
    }
    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(pos, Vector3.one);
    }
}
