# kubeadm setupログ

## containerd
手動で最新をインストール(apt使わない)
```bash
curl -L -LO https://github.com/containerd/containerd/releases/download/v1.7.13/containerd-1.7.13-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo ln -s /lib/systemd/system/containerd.service /etc/systemd/system/multi-user.target.wants/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
```

## containerdのconfig生成・修正
```bash
containerd config default > /etc/containerd/config.toml
```
手動修正
```bash
@@ -62,7 +62,7 @@
     max_container_log_line_size = 16384
     netns_mounts_under_state_dir = false
     restrict_oom_score_adj = false
-    sandbox_image = "registry.k8s.io/pause:3.8"
+    sandbox_image = "registry.k8s.io/pause:3.9"
     selinux_category_range = 1024
     stats_collect_period = 10
     stream_idle_timeout = "4h0m0s"
@@ -134,7 +134,7 @@
             NoPivotRoot = false
             Root = ""
             ShimCgroup = ""
-            SystemdCgroup = false
+            SystemdCgroup = true
 
       [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
         base_runtime_spec = ""
```


## cniプラグイン
同じく手動インストール
```bash
curl -L -O https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz 
```

## kubeletなど
公式ドキュメントの通り
バージョン1.28.2-00（2024/02時点）

## kubeadm
default: 192.168.0.0/16のレンジが自宅networkとかぶるのでPOD CIDR等をずらす
```bash
# master
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.250 --service-cidr=10.244.0.0/16

# masterにもスケジュールできるように
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## calico
[quick start](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)に沿ってインストール

```bash
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml

curl -LO https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
```
CIDR変更
```bash
@@ -10,7 +10,7 @@
     # Note: The ipPools section cannot be modified post-install.
     ipPools:
     - blockSize: 26
-      cidr: 192.168.0.0/16
+      cidr: 10.244.0.0/16
       encapsulation: VXLANCrossSubnet
       natOutgoing: Enabled
       nodeSelector: all()
```
