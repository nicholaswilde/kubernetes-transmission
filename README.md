# Kubernetes Transmission
Deploy the [Transmission BitTorrent client](https://transmissionbt.com/) on a [Kubernetes cluster](https://kubernetes.io/) with an NFS persistent volume.

This repo is based off of the [zebpalmer/kubernetes-transmission-openvpn](https://github.com/zebpalmer/kubernetes-transmission-openvpn) repo. The difference is this setup uses the [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission) Docker image instead of the OpenVPN one. This repo was also made using [kompose](https://github.com/kubernetes/kompose) which takes a Docker Compose file and translates it into Kubernetes resources.

## Prerequisities
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

## Test
This setup has been tested with [Rancher/K3S](https://github.com/rancher/k3s) with [Hypriot](https://github.com/hypriot/image-builder-rpi) on a [Turing Pi](https://turingpi.com/) cluster.

## Download
```bash
$ git clone https://github.com/nicholaswilde/kubernetes-transmission.git
$ cd kubernetes-transmission/
```
## Setup
### Default Namespace
`transmission`
If you'd like to change the namespace, update the `namespace` key in all of the manifests.

### Deployment
Edit the `deployment.yaml` and choose the image that you'd like to use.

```yaml
image: linuxserver/transmission:arm32v7-latest
```
| Architecture | Tag            |
|--------------|----------------|
| x86-64       | amd64-latest   |
| arm64	       | arm64v8-latest |
| armhf	       | arm32v7-latest |

### ConfigMap
Edit the `configMap.yaml` to choose the `TRANSMISSION_WEB_HOME` and change other settings.
```yaml
...
  TRANSMISSION_WEB_HOME: /combustion-release/
  #TRANSMISSION_WEB_HOME: /transmission-web-control/
  #TRANSMISSION_WEB_HOME: /kettu/
...
```
### Secret
The default `USER` and `PASS` for the Web GUI are:
```yaml
USER=pirate
PASS=hypriot
```
To change the `USER` and `PASS` for the web GUI, run the following in the command line and paste the results into `secret.yaml`
```bash
$ echo -n 'pirate' | base64
$ echo -n 'hypriot' | base64
```
### Ingress
Change the `nginx.ingress.kubernetes.io/whitelist-source-range` and `host` variables in the `ingress.yaml` file.
```yaml
...
    nginx.ingress.kubernetes.io/whitelist-source-range: 192.168.1.0/24
...
  - host: transmission.192.168.1.202.nip.io
...
```
### PersistentVolume
This repo is setup to use an NFS PersistentVolume
Edit the `nfs-persistentVolume.yaml`
```yaml
...
  capacity:
    storage: 4T
...
  nfs:
    server: 192.168.1.192
    path: "/home/pi/nas"
...
```

## Installation
### Automatic
```bash
$ chmod +x deploy.sh
$ ./deploy.sh
```

### Manual
```bash
$ kubectl apply -f manifests/namespace.yaml
$ kubectl apply -f manifests/nfs-persistentVolume.yaml
$ kubectl apply -f manifests/persistentVolumeClaim.yaml
$ kubectl apply -f manifests/secret.yaml
$ kubectl apply -f manifests/confgMap.yaml
$ kubectl apply -f manifests/service.yaml
$ kubectl apply -f manifests/deployment.yaml
$ kubectl apply -f manifests/ingress.yaml
```

## Usage
### Running
Check that the pod is running correctly
```bash
$ kubectl get pods -n transmission
NAME                           READY   STATUS    RESTARTS   AGE
transmission-94bc9d45b-9lrxr   1/1     Running   0          94m
```

### Ingress
```bash
$ kubectl get ingress -n transmission
NAME           CLASS    HOSTS                               ADDRESS         PORTS   AGE
transmission   <none>   transmission.192.168.1.202.nip.io   192.168.1.203   80      73m
```
Make sure the IP address in the `HOST` matches the one listed in `ADDRESS`

## Uninstallation
### Automatic
```bash
$ chmod +x deploy.sh
$ ./reset.sh
```
### Manual
```bash
$ kubectl delete all --all -n transmission
$ kubectl delete ingress transmission -n transmission
$ kubectl delete pvc transmission-pvc -n transmission
$ kubectl delete pv pv-nfs
$ kubectl delete secret transmission-creds -n transmission
$ kubectl delete namespace transmission
```
If you are having trouble deleting the namespace, see [knsk](https://github.com/thyarles/knsk).
