# Hello world KEDA
Welcome to my hello-world KEDA project. I hope you will be able to test KEDA in few minuts.

## Requirements
* A Kubernetes cluster 1.18+
* Helm 3.5.4
* Docker 19.03 (optional)

## Deploy tooling
### Deploy KEDA
```bash
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda --namespace keda-system --version 2.1.3
```

### Deploy Kafka
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/kafka
```

In output you will find some information. Here an extract of what we need :
```
Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:

    my-release-kafka-0.my-release-kafka-headless.default.svc.cluster.local:9092

To create a pod that you can use as a Kafka client run the following commands:

    kubectl run my-release-kafka-client --restart='Never' --image docker.io/bitnami/kafka:2.8.0-debian-10-r0 --namespace default --command -- sleep infinity
    kubectl exec --tty -i my-release-kafka-client --namespace default -- bash

    PRODUCER:
        kafka-console-producer.sh \
            --broker-list my-release-kafka-0.my-release-kafka-headless.default.svc.cluster.local:9092 \
            --topic test
```

You may have to update the `kubernetes/deploy.yaml` file with the **kafka broker** value if you have change the helm release name.

The **producer** will allow you to test your **KEDA scaled object**. Create the pod and run the command. Keep it and open a new terminal.

## Build the consumer kafka (optional)
If you want you can build your own container image :
```bash
docker build -t <image_name> .
docker push <image_name>
```

## Deploy Kubernetes resources
### The kafka consumer
If you want to use your own kafka consumer image, you must override `kubernetes/deploy/yaml` file.
```bash
kubectl apply -f kubernetes/deploy.yaml
```
It creates a deployment with 1 replica called **consumer**. Run this command, keep it and open a new terminal.
```
kubectl get deploy -w
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
consumer   1/1     1            1           5s
```

### The KEDA Scaled Object
The ScaledObject is defined like it :
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: scaledobject
  namespace: default
spec:
  maxReplicaCount: 100
  minReplicaCount: 0
  scaleTargetRef:
    name: <deployment's name of the app>
  pollingInterval: 5
  triggers:
    - type: kafka # because we are using kafka
      metadata:
        bootstrapServers: <broker>
        consumerGroup: app_1 # be carefull to use the same as your app
        topic: test
        lagThreshold: '5'
```
You may have to override the `kubernetes/scaler.yaml` file with your own **broker** value.

Currently, you have no message in your queue and 1 consumer which process nothing. Run the following command.

```bash
k apply -f kubernetes/scaler.yaml
```

Wait few seconds, you will see that your deployment will auto scale to 0 because no message are found. Congratulation, it works :tada:. Feel free to play with **ScaledObject** specifications to see what happen.
