using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using Nebukam.ORCA;
using Nebukam.Common;
using Unity.Mathematics;
using static Unity.Mathematics.math;
using XLua;
[LuaCallCSharp]
public class ORCAScene : MonoBehaviour
{
    public void CollectCollsition()
    {
        //List<MapCollider> mapColliders = new List<MapCollider>();
        //GetComponentsInChildren(mapColliders);

    }


    // Start is called before the first frame update
    public float width;
    public float length;

    public float thickness = 0.1f;

    public Agent GetAgent(int index)
    {
        return m_simulation.agents[index];
    }

    private ORCABundle<Agent> m_simulation;

    public void GenerateScene()
    {
        m_simulation = new ORCABundle<Agent>();
        m_simulation.plane = AxisPair.XZ;

        float radius = 0.5f;

        //LEFT
        {
            List<float3> points = new List<float3>();

            points.Add(float3(-width , 0, -length / 2));
            points.Add(float3(width , 0, -length / 2));

            Obstacle o = m_simulation.staticObstacles.Add(points, false);
            o.edge = true;
            o.thickness = thickness;
        }

        //RIGHT
        {
            List<float3> points = new List<float3>();

            points.Add(float3(-width , 0, length / 2));
            points.Add(float3(width , 0, length / 2));

            Obstacle o = m_simulation.staticObstacles.Add(points, true);
            o.edge = true;
            o.thickness = thickness;
        }

        //BOTTOM
        {
            List<float3> points = new List<float3>();

            points.Add(float3(-5 - thickness, 0, -length / 2));
            points.Add(float3(-5 - thickness, 0, length / 2));

            Obstacle o = m_simulation.staticObstacles.Add(points, true);
            o.edge = true;
            o.thickness = thickness;
        }
    }

    List<int> emptyAgent = new List<int>();

    public int AddAgent(Vector3 position,  float radius, float speed)
    {
        int agentIndex;
        Agent agent;
        if(emptyAgent.Count > 0)
        {
            agentIndex = emptyAgent[emptyAgent.Count - 1];
            emptyAgent.RemoveAt(emptyAgent.Count - 1);
            agent = m_simulation.agents[agentIndex];
            agent.collisionEnabled = true;
        }
        else
        {
            agent = m_simulation.NewAgent(position);
            agentIndex = m_simulation.agents.Count - 1;
        }

        agent.radius = radius;
        agent.radiusObst = radius;
        agent.maxSpeed = speed;
        //agent.prefVelocity = normalize(dest - position) * speed;
        //agent.velocity = agent.prefVelocity;
        agent.timeHorizon = 0.001f;

        return agentIndex;
    }

    public static void SetDestination(Agent agent, float dx, float dy)
    {
        float3 dest = new float3(dx, 0, dy);
        agent.prefVelocity = normalize(dest - agent.pos) * agent.maxSpeed;
    }

    public static void SetStop(Agent agent)
    {
        agent.prefVelocity = float3(0, 0, 0);
    }

    //[LuaCallCSharp]
    //List<Type> types = new List<Type>()
    //{
    //    typeof(Agent)
    //}
    public void DoUpdate(float dt = 0.01f)
    {
        m_simulation.orca.TryComplete();
        m_simulation.orca.Schedule(dt);
    }

    public void RemoveAgent(int index)
    {
        Agent agent = m_simulation.agents[index];
        agent.collisionEnabled = false;
        emptyAgent.Add(index);
    }
    //public class Agent : IAgent
    //{

    //}
}
