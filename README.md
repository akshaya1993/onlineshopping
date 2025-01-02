**Kubernetes Deployment and Service Debugging**

**Overview**

This document provides a detailed explanation of the Kubernetes setup, deployment, service configuration, and debugging steps based on the provided logs and commands.

![image](https://github.com/user-attachments/assets/fd95788a-bb48-4457-8d2c-f32823232f7b)


**Prerequisites**

Ensure the following are installed and configured:

3 ec2 instances
1.Jenkins (jre+jenkins)
2.Ansible (python,docker and Ansible)
3.Webapp (kubernetes+docker+minikube)

2 ec2 instances are required of type t2.micro with 10gb storage volume (jenkins and Ansible)
1 ec2 instance of type t2.medium with storage 10 gb(kubernetes)



Deployment YAML:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicdpipeline
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cicdpipeline
  template:
    metadata:
      labels:
        app: cicdpipeline
    spec:
      containers:
      - name: cicdpipeline
        image: <your-docker-image>
        ports:
        - containerPort: 80

Service Configuration

The service exposes the deployment to external traffic:

Service YAML:

apiVersion: v1
kind: Service
metadata:
  name: cicdpipeline
spec:
  type: NodePort
  selector:
    app: cicdpipeline
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 31200

Debugging Steps

1. Verifying Pod and Service Status

Check the status of pods:

kubectl get pods

Example Output:

NAME                                READY   STATUS    RESTARTS   AGE
pod/cicdpipeline-7bc98fbd45-sgqln   1/1     Running   0          10m

Check the status of services:

kubectl get services

Example Output:

NAME           TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
cicdpipeline   NodePort       10.98.47.138   <none>         80:31200/TCP     11m

2. Verifying Pod Connectivity

Ensure the application is listening on the correct port inside the pod:

kubectl exec -it pod/cicdpipeline-7bc98fbd45-sgqln -- netstat -tuln

Example Output:

Proto Recv-Q Send-Q Local Address           Foreign Address         State       
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      

Test internal connectivity:

kubectl exec -it pod/cicdpipeline-7bc98fbd45-sgqln -- curl http://localhost:80

3. Port Forwarding

To test locally:

kubectl port-forward service/cicdpipeline 8080:80

Access the service locally:

curl http://localhost:8080

4. NodePort Access

Access the service via NodePort using the public IP of the node:

curl http://<node-public-ip>:31200

Ensure the security group/firewall allows traffic on port 31200.

5. Logs and Debugging

Check pod logs for any issues:

kubectl logs pod/cicdpipeline-7bc98fbd45-sgqln

Verify kube-proxy functionality:

kubectl logs -n kube-system <kube-proxy-pod-name>

Issues Identified and Fixes

1. Invalid Service Type

The error message:

The Service "cicdpipeline" is invalid: spec.type: Unsupported value: "Loadbalancer": supported values: "ClusterIP", "ExternalName", "LoadBalancer", "NodePort"

Resolution: Ensure the spec.type is correctly set as NodePort or LoadBalancer.

2. Port Mismatch

If the pod is listening on port 80 but the service targets a different port, traffic will fail.
Resolution: Ensure the port and targetPort in the service match the containerPort in the deployment.

3. Connection Issues

The error message:

curl: (7) Failed to connect to localhost port 8080

Resolution:

Restart port forwarding and keep the session active.

Verify firewall rules and security groups to allow traffic.

Additional Notes

Ensure Kubernetes contexts are correctly set:

kubectl config get-contexts
kubectl config use-context <context-name>

Validate cluster health:

kubectl cluster-info
kubectl get nodes
