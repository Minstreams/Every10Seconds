using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 简单触发器按钮
/// </summary>
public class SimpleBottonTrigger : MonoBehaviour
{
    private bool isActive = true;
    private Vector3 originPos;
    private Color[] origColor;
    private int[] probeRenderID;


    public Transform bottonFace;
    public float pressDownDepth = 0.1f;
    public float pressDownTime = 0.5f;
    public float holdDownTime = 3f;
    public AudioSource downAudio;
    public AudioSource upAudio;

    public Renderer[] involvedObjects;
    public ReflectionProbe[] involvedReflectionProbes;
    public MaterialToControl[] materials;
    public LightToControl[] lights;

    [System.Serializable]
    public struct MaterialToControl
    {
        public Material material;
        public string tintName;
        [ColorUsage(true, true)]
        public Color color;
    }

    [System.Serializable]
    public struct LightToControl
    {
        public Light light;
        public float intensity;
    }

    private void Start()
    {
        originPos = bottonFace.localPosition;
        origColor = new Color[materials.Length];
        for (int i = 0; i < materials.Length; i++)
        {
            origColor[i] = materials[i].material.GetColor(materials[i].tintName);
        }
        probeRenderID = new int[involvedReflectionProbes.Length];
        for (int i = 0; i < involvedReflectionProbes.Length; i++)
        {
            probeRenderID[i] = -1;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (isActive && other.CompareTag("Player"))
        {
            StopAllCoroutines();
            StartCoroutine(bottonDown());
        }
    }

    private IEnumerator bottonDown()
    {
        isActive = false;

        //Initiate Variables
        Color[] color = new Color[materials.Length];
        Color[] targetColorDifference = new Color[materials.Length];
        for (int i = 0; i < materials.Length; i++)
        {
            color[i] = materials[i].material.GetColor(materials[i].tintName);
            targetColorDifference[i] = materials[i].color - color[i];
        }

        float[] intensity = new float[lights.Length];
        float[] targetIntensityDifference = new float[lights.Length];
        for (int i = 0; i < lights.Length; i++)
        {
            intensity[i] = lights[i].light.intensity;
            targetIntensityDifference[i] = lights[i].intensity - intensity[i];
        }


        //Press Down
        downAudio.Play();
        for (float timer = 0; timer < pressDownTime; timer += Time.deltaTime)
        {
            bottonFace.Translate(-Vector3.up * pressDownDepth * Time.deltaTime / pressDownTime);
            for (int i = 0; i < materials.Length; i++)
            {
                color[i] += targetColorDifference[i] * Time.deltaTime / pressDownTime;
                materials[i].material.SetColor(materials[i].tintName, color[i]);
            }
            foreach (Renderer r in involvedObjects)
            {
                r.UpdateGIMaterials();
            }
            for (int i = 0; i < lights.Length; i++)
            {
                intensity[i] += targetIntensityDifference[i] * Time.deltaTime / pressDownTime;
                lights[i].light.intensity = intensity[i];
            }
            for (int i = 0; i < involvedReflectionProbes.Length; i++)
            {
                if (probeRenderID[i] < 0 || involvedReflectionProbes[i].IsFinishedRendering(probeRenderID[i]))
                {
                    probeRenderID[i] = involvedReflectionProbes[i].RenderProbe();
                }
            }
            yield return 0;
        }

        //End State
        bottonFace.localPosition = originPos - Vector3.up * pressDownDepth;
        for (int i = 0; i < materials.Length; i++)
        {
            materials[i].material.SetColor(materials[i].tintName, materials[i].color);
        }
        for (int i = 0; i < lights.Length; i++)
        {
            lights[i].light.intensity = lights[i].intensity;
        }
        foreach (Renderer r in involvedObjects)
        {
            r.UpdateGIMaterials();
        }
        yield return checkRpRendered();
        for (int i = 0; i < involvedReflectionProbes.Length; i++)
        {
            probeRenderID[i] = involvedReflectionProbes[i].RenderProbe();
        }
        yield return checkRpRendered();
        for (int i = 0; i < involvedReflectionProbes.Length; i++)
        {
            probeRenderID[i] = -1;
        }

        //Hold
        yield return new WaitForSeconds(holdDownTime);


        //Release Up
        upAudio.Play();
        for (float timer = 0; timer < pressDownTime; timer += Time.deltaTime)
        {
            bottonFace.Translate(Vector3.up * pressDownDepth * Time.deltaTime / pressDownTime);

            yield return 0;
        }

        bottonFace.localPosition = originPos;

        isActive = true;
    }

    private IEnumerator checkRpRendered()
    {
        bool rpRendered;
        do
        {
            rpRendered = true;
            for (int i = 0; i < involvedReflectionProbes.Length; i++)
            {
                rpRendered = rpRendered && (probeRenderID[i] < 0 || involvedReflectionProbes[i].IsFinishedRendering(probeRenderID[i]));
            }
            yield return 0;
        } while (!rpRendered);
    }

    private void OnDestroy()
    {
        for (int i = 0; i < materials.Length; i++)
        {
            materials[i].material.SetColor(materials[i].tintName, origColor[i]);
        }
    }
}
