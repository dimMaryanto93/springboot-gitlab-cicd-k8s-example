# Installing Kubernetes cluster

Kita siapkan host yang akan di install kubernetes, sebagai contoh disini saya menggunakan CentOS 8 dengan konfigurasi minimal sebagai berikut:

```yaml
Master-Node:
    - NodeName: 'k8s-master'
      CPU: '2 Cores'
      RAM: '4 GB'
      Storage: '50 GB'
        partision: 
          - / = "20 Gb"
          - /var = "30 Gb"
          - swap = "Disabled"
      Network: 
        - IP4: 'Brige (192.168.88.140)'
        - hostname: 'k8s-master.example.com'
Worker-Nodes: 
    - NodeName: 'k8s-worker1'
      CPU: '2 Cores'
      RAM: '2 GB'
      Storage: '50 GB'
        partision:
          - / = "20 Gb"
          - /var = "30 Gb"
          - swap = "Disabled"
      Network: 
        - IP4: 'Brige (192.168.88.14x)'
        - hostname: 'k8s-worker1.example.com'
```

## Setup & install commons package

Sebelum kita install, disini saya mau install dulu commons package seperti `curl`, `wget`, `yum-utils`, `net-tools` dan lain-lain.

```bash
# update system
yum install -y update && \
yum install -y net-tools curl wget yum-utils vim tmux && \
yum install -y device-mapper-persistent-data lvm2 fuse-overlayfs
```

Disable swap partition permanently, edit file `/etc/fstab` comment `/dev/mapper/cl-swap` like this:

```conf
#
# /etc/fstab
# Created by anaconda on Tue Jul 20 08:07:33 2021
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/cl-root                         /                       xfs     defaults        0 0
UUID=4ec37475-d403-4466-b2bf-318dfd409092   /boot                   ext4    defaults        1 2
/dev/mapper/cl-var                          /var                    xfs     defaults        0 0
#/dev/mapper/cl-swap                        swap                    swap    defaults        0 0
```

Setelah itu kita set selinux = `permissive` dengan mengedit file `/etc/selinux/config` 

```bash
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config && \
systemctl disable firewalld && \
systemctl stop firewalld
```

Kemudian `reboot` . 

Setelah itu kita setup untuk networking (iptables) di kubernetes.

Make sure that the `br_netfilter` module is loaded. This can be done by running `lsmod | grep br_netfilter`. To load it explicitly call `sudo modprobe br_netfilter`.
As a requirement for your Linux Node’s iptables to correctly see bridged traffic, you should ensure `net.bridge.bridge-nf-call-iptables` is set to 1 in your `sysctl` config, e.g.

```bash
lsmod | grep br_netfilter && \
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
```

## Installing docker as kubernetes runtime

Install the `yum-utils` package (which provides the yum-config-manager utility) and set up the stable repository.

```bash
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo && \
yum install -y docker-ce docker-ce-cli containerd.io && \
sudo mkdir -p /etc/docker && \
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "insecure-registries": [
    "repository.dimas-maryanto.com:8087",
    "repository.dimas-maryanto.com:8086"
  ]
}
EOF
```

Kemudian jalankan service dockernya, dengan perintah seperti berikut:

```bash
systemctl enable --now docker
```

## Install Kubernetes CLI

You will install these packages on all of your machines:

1. `kubeadm`: the command to bootstrap the cluster.
2. `kubelet`: the component that runs on all of the machines in your cluster and does things like starting pods and containers. 
3. `kubectl`: the command line util to talk to your cluster.

Kita bisa menggunakan package manager Red Hat-based distribution seperti berikut:

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes && \
sudo setenforce 0 && \
sudo systemctl enable --now kubelet
```
