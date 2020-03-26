## Hybrid Kubernetes Cluster

Kinda...

Many organizations with .NET workloads are moving them to Kubernetes. You can run new .NET Core apps in Linux containers on Kubernetes alongside old .NET Framework apps in Windows containers, with a mixed Linux & Windows cluster.

You can't do that with Docker Desktop because the Kubernetes cluster is Linux-only, but you can approximate it...

I'm in Linux container mode, running Kubernetes in Docker Desktop:

```
docker version

kubectl get nodes
```

Deploy the [Pi demo app](./specs/web/web.yaml), which is .NET Core so it can run in Linux containers with Kubernetes:

```
kubectl apply -f ./specs/web/
```

Check the app with some Pi calculations and the metrics:

- http://localhost:8088/Pi?dp=5000

Deploy [Prometheus](./specs/prometheus/prometheus.yaml) which the app uses for monitoring:

```
kubectl apply -f ./specs/prometheus/
```

Check Prometheus at http://localhost:9090 and graph `pi_compute_duration_seconds_count`.

## Add a legacy Windows component

There's also an old WCF API for the Pi app - in a mixed Kubernetes cluster that could run in a pod on a Windows node, but you can't do that on Docker Desktop.

Instead we'll run the WCF app as a standalone Windows container and connect it via the host network to the Kubernetes pods.

> Switch to Windows Container mode and run the old WCF service:

```
docker container run -d -p 8089:80 -p 50505:50505 --name pi sixeyed/pi:wcf-2002
```

Check the app and its metrics:

- http://localhost:8089/PiService.svc/Pi?dp=1800

Prometheus is configured to scrape a target called `pi-wcf` but there's no DNS entry for that in the cluster so it's failing - http://localhost:9090/targets.

## Add a Kubernetes Service for the Windows container

```
kubectl apply -f ./wcf/wcf-service-headless.yaml
```

Check [targets](http://localhost:9090/targets) and [graph](http://localhost:9090) again - metrics for the Linux and Windows containers are there :)
