using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 企鹅控制器
/// </summary>
public class PenguinController : MonoBehaviour
{
    /// <summary>
    /// 记录鼠标所指位置
    /// </summary>
    private RaycastHit raycastHit;
    private Vector3 raycastHitPoint;



    //Lighter Parameters
    [Header("【手电筒参数】")]
    [Header("手电筒")]
    public Transform lighter;
    [Header("灯光物体")]
    public GameObject realLight;
    [Header("开灯时间")]
    public float raiseLighterTime = 0.5f;
    private bool isLighterUp = false;
    private float lighterIKWeight = 0.0f;
    private Coroutine lighterTurnCoroutine;
    public AudioSource[] lighterSounds;
    public List<ReflectionProbe> involvedReflectionProbes;


    //Gun Parameters
    [Header("【枪参数】")]
    [Header("枪")]
    public Transform gun;
    private Quaternion gunOriginRotation;
    [Header("枪口")]
    public Transform gunPoint;
    [Header("举枪时间")]
    public float raiseGunTime = 0.3f;
    [Header("后坐力偏移量")]
    public float forceBackward = 0.4f;
    [Header("中心还原率"), Range(0, 1)]
    public float pivotReboundRate = 0.7f;
    public MyScriptableObject.AmmoMaterial ammoMaterial;
    //public Cinemachine.PostFX.CinemachinePostFX cinemachine;
    public AudioSource[] gunSounds;
    public ParticleSystem gunShotParticleSystem;
    public ParticleSystem gunShotHitParticle;
    public float gunShotDistance = 40;
    public LayerMask ammoLayerMask;
    public LineRenderer lineRenderer;
    public Color lineColor;
    public float lineLifeTime = 0.2f;

    private bool isGunUp = false;
    private float gunIKWeight = 0.0f;
    private Coroutine gunTurnCoroutine;
    private Coroutine lineCoroutine;


    //Move Parameters
    [Header("【移动参数】"), SerializeField]
    private LayerMask inputRayLayerMask;
    [Header("【聚焦中心】"), SerializeField]
    private Transform focusPivot;
    [Header("空手速度加成"), SerializeField, Range(0, 1)]
    private float speedBonusEmptyHanded = 0.75f;
    [Header("旋转速率"), SerializeField, Range(0.001f, 1)]
    private float rotateRate = 0.07f;

    private bool flip = false;  //转身
    private float rotateParameter = 0;  //动画参数
    private float rotateAc = 0;  //加速度
    private const float rotateAcFactor = 0.2f;  //加速度转换常量
    [Header("转身阈值"), SerializeField, Range(0.001f, 1)]
    private float flipThreshold = 0.1f;
    [Header("动画参数归零比率"), SerializeField, Range(0.001f, 1)]
    private float rotateDyingRate = 0.96f;
    [Header("瞄准平滑比率"), SerializeField, Range(0.001f, 1)]
    private float raycastPointMoveRate = 0.2f;

    //Reference Variables
    private Animator anim;

    private void Awake()
    {
        anim = GetComponent<Animator>();
    }
    private void Start()
    {
        gunSounds[0].clip = ammoMaterial.GunShotAudio;
        gunOriginRotation = gun.localRotation;
    }

    //private void OnCollisionEnter(Collision collision)
    //{
    //    print(collision.gameObject);
    //}

    public void TurnLight(bool b)
    {
        isLighterUp = b;
        if (raiseLighterTime == 0)
        {
            realLight.SetActive(b);
            lighterIKWeight = b ? 1 : 0;
        }
        else
        {
            if (lighterTurnCoroutine != null)
                StopCoroutine(lighterTurnCoroutine);
            lighterTurnCoroutine = StartCoroutine(turnLight(b));
        }
    }
    private IEnumerator turnLight(bool b)
    {
        if (!b)
        {
            realLight.SetActive(false);
            lighterSounds[1].Play();

            int[] probeRenderID = new int[involvedReflectionProbes.Count];
            for (int i = 0; i < involvedReflectionProbes.Count; i++)
            {
                probeRenderID[i] = involvedReflectionProbes[i].RenderProbe();
            }
            bool rpRendered;
            do
            {
                rpRendered = true;
                for (int i = 0; i < involvedReflectionProbes.Count; i++)
                {
                    rpRendered = rpRendered && (probeRenderID[i] < 0 || involvedReflectionProbes[i].IsFinishedRendering(probeRenderID[i]));
                }
                yield return 0;
            } while (!rpRendered);
        }
        float temp = lighterIKWeight;
        float gap = (b ? 1 : 0) - temp;

        while (b ? temp < 1 : temp > 0)
        {
            lighterIKWeight = temp;
            yield return 0;
            temp += gap * Time.deltaTime / raiseLighterTime;
        }

        lighterIKWeight = b ? 1 : 0;
        if (b)
        {
            realLight.SetActive(true);
            lighterSounds[0].Play();
        }
    }

    public void TurnGun(bool b)
    {
        isGunUp = b;
        if (raiseGunTime == 0)
        {
            gunIKWeight = b ? 1 : 0;
            if (!b)
            {
                gun.localRotation = Quaternion.Euler(-90, 90, 0);
            }
        }
        else
        {
            if (gunTurnCoroutine != null)
                StopCoroutine(gunTurnCoroutine);
            gunTurnCoroutine = StartCoroutine(turnGun(b));
        }
    }
    private IEnumerator turnGun(bool b)
    {
        float temp = gunIKWeight;
        float gap = (b ? 1 : 0) - temp;

        while (b ? temp < 1 : temp > 0)
        {
            gunIKWeight = temp;
            yield return 0;
            temp += gap * Time.deltaTime / raiseGunTime;
        }

        gunIKWeight = b ? 1 : 0;

        if (!b)
        {
            gun.localRotation = Quaternion.Euler(-90, 90, 0);
        }
    }
    public void Fire(Vector3 target)
    {
        gunSounds[0].Play();

        RaycastHit ammoHit;
        Vector3 ammoDir = (target - gunPoint.position).normalized;

        //后坐力
        gun.Translate(-ammoDir * forceBackward / 6.0f, Space.World);
        focusPivot.Translate(-ammoDir * forceBackward, Space.World);

        bool hited = Physics.Raycast(gunPoint.position, ammoDir, out ammoHit, gunShotDistance, ammoLayerMask.value);

        gunShotParticleSystem.Emit(Random.Range(2, 5));

        lineRenderer.SetPosition(0, gunPoint.position);
        lineRenderer.SetPosition(1, hited ? ammoHit.point : gunPoint.position + ammoDir * gunShotDistance);
        if (lineCoroutine != null)
        {
            StopCoroutine(lineCoroutine);
        }
        lineCoroutine = StartCoroutine(lineFade());

        if (hited)
        {
            gunShotHitParticle.transform.position = ammoHit.point;
            gunShotHitParticle.transform.rotation = Quaternion.LookRotation(ammoHit.normal);
            gunShotHitParticle.Emit(Random.Range(2, 5));
            gunSounds[1].Play();

            Harm(ammoHit, ammoDir);
        }
    }

    /// <summary>
    /// 伤害判定
    /// </summary>
    /// <param name="ammoHit"></param>
    public void Harm(RaycastHit ammoHit, Vector3 ammoDir)
    {
        HarmableObject ho = ammoHit.collider.GetComponentInParent<HarmableObject>();
        if (ho != null)
        {
            ho.Harm(ammoMaterial, ammoHit, ammoDir);
        }

        if (ammoHit.collider.attachedRigidbody != null)
        {
            ammoHit.collider.attachedRigidbody.AddForceAtPosition(ammoDir * ammoMaterial.GetMomentum(), ammoHit.point, ForceMode.Impulse);
        }
    }

    private IEnumerator lineFade()
    {
        Color c = lineColor;

        while (c.a > 0)
        {
            c.a -= Time.deltaTime / lineLifeTime;
            lineRenderer.endColor = c;
            yield return 0;
        }
        c.a = 0;
        lineRenderer.endColor = c;
    }

    private void Update()
    {
        //手电筒方向
        if (isLighterUp) lighter.LookAt(raycastHitPoint);

        float reboundRate = Mathf.Pow(pivotReboundRate, Time.timeScale);
        //Gun位置方向
        gun.localPosition *= reboundRate;
        gun.localRotation = Quaternion.Lerp(gunOriginRotation, Quaternion.Inverse(gun.parent.rotation) * Quaternion.LookRotation(raycastHitPoint - gunPoint.position), gunIKWeight);
        //中心还原
        focusPivot.localPosition *= reboundRate;

        //输入
        if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out raycastHit, 100, inputRayLayerMask.value))
        {
            raycastHitPoint += raycastPointMoveRate * (raycastHit.point - raycastHitPoint);
        }
        bool rightMouseDown = Input.GetMouseButton(1);
        if (rightMouseDown != isGunUp)
        {
            TurnGun(rightMouseDown);
        }
        if (Input.GetKeyDown(KeyCode.F))
        {
            TurnLight(!isLighterUp);
        }
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        if (isGunUp && Input.GetMouseButtonDown(0))
        {
            Fire(raycastHitPoint);
        }
        //cinemachine.m_FocusOffset = gunIKWeight * Vector3.Dot((raycastHitPoint - transform.position), Camera.main.transform.forward);

        //计算前进方向
        Vector3 forward = (Camera.main.transform.right * h + Vector3.Cross(Camera.main.transform.right, Vector3.up) * v).normalized;    //目标前进方向归一化向量

        //计算视线方向
        Vector3 sightDir = (raycastHitPoint - transform.position).normalized;   //视线方向归一化向量
        float sightAngle = Vector3.SignedAngle(transform.forward, sightDir, Vector3.up);  //视线转角

        //反转
        float tempDot = Vector3.Dot(sightDir, Vector3.Cross(Vector3.up, forward));
        if (flip != tempDot < 0)
        {
            //若过阈值则转身
            flip = tempDot < -flipThreshold;
        }

        float angle = sightAngle;   //转向角
        float currentSpeed = 0; //前进速度

        //若走动了
        if (h != 0 || v != 0)
        {
            //计算速度
            float hh = h * h;
            float vv = v * v;
            float speedSq = (hh + vv) / (1 + (hh > vv ? vv / hh : hh / vv));    //速度的平方

            currentSpeed = (Vector3.Dot(transform.forward, forward) * speedSq) * (1 + Input.GetAxis("Fire3")/*奔跑系数*/* (1.0f + (1 - gunIKWeight * 0.5f) * (1 - lighterIKWeight) * speedBonusEmptyHanded));

            //计算angle
            Vector3 targetFaceForward = ((isLighterUp || isGunUp) && flip) ? -forward : forward;
            angle = Vector3.SignedAngle(transform.forward, targetFaceForward, Vector3.up);
            if ((isLighterUp || isGunUp) && (sightAngle > 0 ? angle < -90 : angle > 90))
            {
                angle += angle > 0 ? -360 : 360;    //反向
            }

            //Debug.DrawLine(transform.position + Vector3.up * 0.6f, transform.position + Vector3.up * 0.6f + targetFaceForward * 3, Color.green);
        }

        //播放转身动画
        rotateAc = Mathf.Sin(angle * Mathf.PI / 360.0f) * rotateAcFactor;
        rotateParameter += rotateAc;
        rotateParameter *= rotateDyingRate;
        anim.SetFloat("turn", rotateParameter > 0 ? Mathf.Clamp01(rotateParameter - 0.3f) : -Mathf.Clamp01(-0.3f - rotateParameter));
        transform.Rotate(Vector3.up, angle * (1 - Mathf.Pow(1 - rotateRate, Time.timeScale)));

        //播放行走动画
        anim.SetFloat("speed", currentSpeed);

        //Debug Draw
        //Debug.DrawLine(transform.position + Vector3.up * 0.6f, transform.position + Vector3.up * 0.6f + forward * 5, Color.yellow); //目标前进方向
        //Debug.DrawLine(transform.position + Vector3.up * 0.6f, transform.position + Vector3.up * 0.6f + transform.forward * 2, Color.white, 0.1f);  //实际面朝方向

    }
    private void OnAnimatorIK(int layerIndex)
    {
        //视线位置
        anim.SetLookAtWeight(0.5f + Mathf.Clamp01(lighterIKWeight + gunIKWeight) * 0.5f, 0.5f, 0, 0, 1);
        anim.SetLookAtPosition(raycastHitPoint);

        //左手位置
        anim.SetIKPositionWeight(AvatarIKGoal.LeftHand, 0.5f * lighterIKWeight);
        anim.SetIKRotationWeight(AvatarIKGoal.LeftHand, lighterIKWeight);
        anim.SetIKPosition(AvatarIKGoal.LeftHand, raycastHitPoint);
        anim.SetIKRotation(AvatarIKGoal.LeftHand, Quaternion.LookRotation(raycastHitPoint - transform.position - Vector3.up * 0.7f));

        //右手位置
        anim.SetIKPositionWeight(AvatarIKGoal.RightHand, 0.5f * gunIKWeight);
        anim.SetIKRotationWeight(AvatarIKGoal.RightHand, gunIKWeight);
        anim.SetIKPosition(AvatarIKGoal.RightHand, raycastHitPoint);
        anim.SetIKRotation(AvatarIKGoal.RightHand, Quaternion.LookRotation(raycastHitPoint - transform.position));
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(raycastHitPoint, 1.0f);
        Vector3 startPoint = transform.position + Vector3.up * 0.2f;
        if (isGunUp)
        {
            startPoint = gunPoint.position;
        }
        else if (isLighterUp)
        {
            startPoint = lighter.position;
        }
        Gizmos.DrawLine(startPoint, raycastHitPoint);
    }
#endif
}
