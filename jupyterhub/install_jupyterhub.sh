source ./.jupyterhub.config

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
  --namespace $NAMESPACE  \
  --version=0.8.2 \
  --set proxy.secretToken=$SECRET_TOKEN
