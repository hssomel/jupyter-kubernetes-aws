# jupyter-kubernetes-aws

## Project Overview:
A platform for hosting machine learning and data science workloads. This project integrates and simultaneously deploys Jupyterhub and Jupyterhub Enterprise Gateway on AWS cloud platform via Kubernetes.  

#### Jupyterhub Overview:
Jupyterhub provides user a web interface to interact with and spins up single-user server notebooks. The existing resources and documentation for deploying Jupyterhub as a kubernetes deployment using the following link: [https://zero-to-jupyterhub.readthedocs.io/en/latest/index.html](https://zero-to-jupyterhub.readthedocs.io/en/latest/index.html)
Currently, Jupyterhub deployed via kubernetes, by following the steps provided in the original documentations, will deploy single-user notebook server instances as pods across the cluster. Each individual user will have their own notebook server pod, however, individual kernels and workloads launched within those notebook server pods will remain hosted on the same pod.

