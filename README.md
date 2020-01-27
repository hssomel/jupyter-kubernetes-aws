# jupyter-kubernetes-aws

## Project Overview:
A platform for hosting machine learning and data science workloads. This project integrates and simultaneously deploys Jupyterhub and Jupyterhub Enterprise Gateway on AWS cloud platform via a Kubernetes deployment.  

### Jupyterhub Overview:
Jupyterhub provides user a web interface to interact with and spins up single-user server notebooks. The existing resources and documentation for deploying Jupyterhub as a kubernetes deployment using the following link: <br/>
[https://zero-to-jupyterhub.readthedocs.io/en/latest/index.html](https://zero-to-jupyterhub.readthedocs.io/en/latest/index.html)
Currently, Jupyterhub deployed via kubernetes, by following the steps provided in the original documentations, will deploy single-user notebook server instances as pods across the cluster. Each individual user will have their own notebook server pod, however, individual kernels and workloads launched within those notebook server pods will remain hosted on the same pod.

### Jupyter Enterprise Gateway Overview:
Jupyter Enterprise Gateway is a web server that enables the ability to launch kernels on behalf of remote notebooks. The existing resources for deploying Enterprise Gateway can be found using the link:<br/>
[https://jupyter-enterprise-gateway.readthedocs.io/en/latest/kernel-kubernetes.html](https://jupyter-enterprise-gateway.readthedocs.io/en/latest/kernel-kubernetes.html). 
Enterprise Gateway comes built-in with the following kernels:
- R_kubernetes
- python_kubernetes
- python_tf_gpu_kubernetes
- python_tf_kubernetes
- scala_kubernetes
- spark_R_kubernetes
- spark_python_kubernetes
- spark_scala_kubernetes

#### 
