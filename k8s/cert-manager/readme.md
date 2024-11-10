# k8s/cert-manager
i use cert-manager to automatically renew certificates in my k8s cluster 

# installation string
```
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager \
  --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" \
  --set config.kind="ControllerConfiguration" \
  --set config.enableGatewayAPI=true
```