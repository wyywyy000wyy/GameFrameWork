using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class TestScript : MonoBehaviour
{
    public InputAction actionA;
    public InputAction actionB;
    public InputAction actionX;
    public InputAction actionY;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(actionA.triggered)
        {
            Debug.Log("A");
        }
        if(actionB.triggered)
        {
            Debug.Log("B");
        }
        if(actionX.triggered)
        {
            Debug.Log("X");
        }
        if(actionY.triggered)
        {
            Debug.Log("Y");
        }
    }

    public void OnEnable()
    {
        actionA.Enable();
        actionB.Enable();
        actionX.Enable();
        actionY.Enable();
    }

    public void OnDisable()
    {
        actionA.Disable();
        actionB.Disable();
        actionX.Disable();
        actionY.Disable();
    }
}
