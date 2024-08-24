using System.Numerics;
using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;
using Quaternion = UnityEngine.Quaternion;
using System.Runtime.InteropServices.WindowsRuntime;
[XLua.LuaCallCSharp]
public class BattleEffectConfig : MonoBehaviour
{
    public enum MoveType
    {
        Stay = 1,
        StayTarget = 2,
        __null_ = 3,
        Move = 4,
        Distance = 5,
        // MoveBack = 4,
    }

    // 挂点类型
    public enum HangingType
    {
        None = 0, // 未指定
        Head = 1, // 头部
        Body = 2, // 身体
        Foot = 3 // 脚底
    }
    
    [Header("特效类型")]
    public MoveType moveType = MoveType.Stay;
    [Header("特效挂点(rpg战斗)")]
    public HangingType hangingType = HangingType.None;
    [Header("播放时长(不带位移)")]
    public float playTime = 1f;
    [Header("飞行速度(带位移)")]
    public float flySpeed = 1f;
    [Header("飞行高度(抛物线)")]
    public float flyHeight = 0f;
    [Header("延迟显示")]
    public float delayTime = 0f;
    [Header("延迟销毁")]
    public float keepTime = 0f;
    [Header("定时触发下一动作")]
    public float waitNext = 0f;
    [Header("固定朝向")]
    public bool fixedRotation = false;
    [Header("音效延迟")]
    public float waitSound = 0f;


    private float defaultSpeed = 1f;
    public float Distance
    {
        set
        {
            if (ps == null)
            {
                Debug.LogError("没找到ParticleSystem " + gameObject);
                return;
            }
            var vel = ps.velocityOverLifetime;
            vel.xMultiplier = defaultSpeed * value;
        }
    }
    private int defaultBurstCount = 0;
    private ParticleSystem.EmissionModule em;
    private float defaultNum = 3f;
    // 传入特效比例
    public float Num
    {
        set
        {
            if (ps == null)
            {
                Debug.LogError("没找到ParticleSystem " + gameObject);
                return;
            }
            em.rateOverTimeMultiplier = defaultNum * value;
            if (defaultBurstCount > 0)
            {
                em.burstCount = (int)Math.Round(defaultBurstCount * value);
            }
        }
    }
    private List<ParticleSystem.Burst> burst_list;
    private ParticleSystem ps;
    private void Awake()
    {
        ps = gameObject.GetComponent<ParticleSystem>();
        if (ps == null)
        {
            ps = transform.GetChild(0).GetComponent<ParticleSystem>();
        }
        if (ps != null)
        {
            em = ps.emission;
            defaultSpeed = ps.velocityOverLifetime.xMultiplier;
            defaultNum = em.rateOverTimeMultiplier;
            defaultBurstCount = em.burstCount;
        }
    }

    List<ParticleSystem> particles;
    public void SetTimeScale(float scale, bool force = true)
    {
        if (particles == null)
        {
            particles = new List<ParticleSystem>();
            GetComponentsInChildren<ParticleSystem>(particles);
        }
        else if (force)
        {
            particles.Clear();
            GetComponentsInChildren<ParticleSystem>(particles);
        }
        for(int i = 0; i < particles.Count; i++)
        {
            if(particles[i] == null)
            {
                continue;
            }
            var particle = particles[i].main;
            particle.simulationSpeed = scale;
        }
    }
}