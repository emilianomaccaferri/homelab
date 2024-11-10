# cilium
i decided to use cilium because i can run my application without worrying about other software-defioend infrastructure: `LoadBalancer` services, gateway api support, l2 advertising for ips, network policies, `kube-proxy`-less routing and much more comes pretty much out of the box with cilium, and i don't need to run additional stuff (such as metallb or nginx-fabric) for my applications, which is quite cool.

# installation string
```
cilium install --version 1.16.3 \
    --set kubeProxyReplacement=true \
    --set gatewayAPI.enabled=true \
    --set l2announcements.enabled=true \
    --set k8sClientRateLimit.qps=32 \
    --set k8sClientRateLimit.burst=42 \
    --set k8sServiceHost=11.11.11.253 \
    --set k8sServicePort=6443 \
    --set devices='{eth+,ens+,enp+}' \
    --set envoy.securityContext.capabilities.keepCapNetBindService=true
```