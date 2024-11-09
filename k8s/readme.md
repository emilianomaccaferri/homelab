# k8s
my k8s cluster is entirely setup with `kubeadm` and it's using `crio` as the main container runtime on each node.
<br>
every node is virtualized and is running the fedora-41-server cloud image.

# installation
my k8s (v1.31) nodes come from a template i obtained with the following steps:
- installing crio: https://github.com/cri-o/packaging/blob/main/README.md#distributions-using-rpm-packages
- removing swap:
    ```bash
    sudo swapoff -a
    sudo dnf remove zram-generator-defaults
    ```
- modify the [pause image]() for crio:
  ```
  # /etc/crio/crio.conf.d/10-crio.conf
  ...
  [crio.image]
  ...
  pause_image="registry.k8s.io/pause:3.10"
  ```
- restart crio:
  ```bash
  sudo systemctl start crio.service
  ```
- load required kernel modules:
  ```
    # add the following lines to /etc/modules-load.d/k8s-modules.conf
    # or whatever file you have in modules-load.d
    br_netfilter
    overlay
  ```
- enable ip forwarding:
  ```
  # add the following line in /etc/sysctl.d/99-sysctl.conf
  # or whatever file you have in sysctl.d

  net.ipv4.ip_forward=1

  # and then run
  sudo sysctl -p
  ```
- done, you can boostrap your cluster with:
  ```
  sudo kubeadm init
  ```