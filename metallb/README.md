# MetalLB

## 構築メモ

### install
```bash
# kube-proxyのARP
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

# helm install
helm repo add metallb https://metallb.github.io/metallb
kubectl create namespace metallb-system
helm install metallb metallb/metallb -n metallb-system
```

### address range
```bash
echo '
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.210-192.168.1.230
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default
' | kubectl apply -f -
```

### test
linkerdのsample appをLBでexposeしてみる
```bash
echo '
apiVersion: v1
kind: Service
metadata:
  name: web-svc-lb
  namespace: emojivoto
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: web-svc
' | kubectl apply -f -
```
