# Terraform Module for Kubernetes

Tiny TF module for HobbyFarm that provisions a simple Kubernetes pod. 

Mounts a secret containing the public key at /root/.ssh/authorized_keys

Use any image that has `sshd`. I recommend `ebauman/sshd`, which is also based on this repository (see Dockerfile)
