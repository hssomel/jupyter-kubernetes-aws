# jupyter-kubernetes-aws

## Project Overview:
A platform for hosting machine learning and data science workloads. This project integrates and simultaneously launches Jupyterhub & Jupyter Enterprise Gateway on AWS cloud platform via a Kubernetes deployment.  

### Prerequisites
- A working cluster with Kubernetes and Helm pre-installed.

### Jupyterhub Overview:
Jupyterhub allows clients to connect to notebook-server instances via a web interface. The existing resources for deploying Jupyterhub via kubernetes can be accessed using the following link: <br/>
[https://zero-to-jupyterhub.readthedocs.io/en/latest/index.html](https://zero-to-jupyterhub.readthedocs.io/en/latest/index.html)<br/>
The documentation in the link above has Jupyterhub configured to launch a single pod per user which hosts the notebook-server image. All kernel instances launched by the client will remain hosted in the same notebook-server pod. The integration of the notebook-server instance to Enterprise-Gateway eliminates that restriction and allows each kernel instance to be hosted inside its own pod thereby making full use of cluster resources.

### Jupyter Enterprise Gateway Overview:
Jupyter Enterprise Gateway is a web server that enables the ability to launch kernels on behalf of remote notebooks. The existing resources for deploying Enterprise Gateway can be found using the link:<br/>
[https://jupyter-enterprise-gateway.readthedocs.io/en/latest/kernel-kubernetes.html](https://jupyter-enterprise-gateway.readthedocs.io/en/latest/kernel-kubernetes.html)<br/>
Enterprise Gateway comes built-in with the following kernels:
- R_kubernetes
- python_kubernetes
- python_tf_gpu_kubernetes
- python_tf_kubernetes
- scala_kubernetes
- spark_R_kubernetes
- spark_python_kubernetes
- spark_scala_kubernetes

#### Customization to Jupyterhub Deployment
The team modified the notebook-server image utilized by Jupyterhub when deploying notebook-server pods. Currently, the latest stable release of Jupyterhub is 0.8.2 which utilizes a notebook server image that does not have the "NB2KG" extension installed. This extension is needed for the notebook server to connect to Enterprise Gateway. Thus, the team modified the existing notebook server image to include this extension.

### How to Use:
This repository deploys Jupyterhub and Jupyter Enterprise Gateway utilizing Helm. Once an appropriate cluster is initialized, clone the repository and cd into the directory with the helm repository 
```
cd /jupyter-kubernetes-aws/helm_enterprise_jupyter
```
