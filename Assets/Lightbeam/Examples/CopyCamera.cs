using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CopyCamera : MonoBehaviour
{
    public Camera targetCamera;
    public Camera cam;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (null != targetCamera)
        {
            if (null == cam)
                cam = GetComponent<Camera>();

            cam.fieldOfView = targetCamera.fieldOfView;
            cam.nearClipPlane = targetCamera.nearClipPlane;
            cam.farClipPlane = targetCamera.farClipPlane;
            cam.transform.position = targetCamera.transform.position;
            cam.transform.forward = targetCamera.transform.forward;
        }
    }
}
