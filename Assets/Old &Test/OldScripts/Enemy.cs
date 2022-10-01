using System.Collections;
using System.Collections.Generic;
using MyScriptableObject;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(Animator))]
public class Enemy : HarmableObject
{
    private Animator anim;
    private NavMeshAgent agent;
    private void Awake()
    {
        anim = GetComponent<Animator>();
        agent = GetComponent<NavMeshAgent>();
    }

    private void Start()
    {
        Reborn();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            Reborn();
        }
        if (Input.GetKeyDown(KeyCode.T))
        {
            Die();
        }
        if (Input.GetKeyDown(KeyCode.Y)&&agent!=null)
        {
            agent.SetDestination(GameObject.FindGameObjectWithTag("Player").transform.position);
        }
    }

    public override void Harm(AmmoMaterial ammoMaterial, RaycastHit ammoHit, Vector3 ammoDir)
    {
        Die();
    }
    public void Die()
    {
        foreach (Rigidbody rb in GetComponentsInChildren<Rigidbody>())
        {
            rb.isKinematic = false;
        }
        anim.enabled = false;
    }
    public void Reborn()
    {
        foreach(Rigidbody rb in GetComponentsInChildren<Rigidbody>())
        {
            rb.isKinematic = true;
        }
        anim.enabled = true;
    }
}
