from typing import Mapping
from constructs import Construct
from cdk8s import *
from cdk8s_plus_25 import *

class GreetingsApp(Chart):
    def __init__(self, scope: Construct, ns: str, **kwargs):
        super().__init__(scope, ns, **kwargs)
        
        domain = "lab.io"
        host = ns+"."+domain

        # Create a namespace
        namespace = Namespace(self, "greetings")
        
        env_vars = {
            "CUSTOMER": EnvValue.from_value(ns.upper())
        }

        # Create a deployment
        deployment = Deployment(namespace, "greetings",
            metadata=ApiObjectMetadata(namespace=namespace.name),
            containers=[
                ContainerProps(
                    name="greetings-{}".format(ns),
                    image="registry.lab.io:5000/greetings:1.0.0",
                    image_pull_policy=ImagePullPolicy(ImagePullPolicy.ALWAYS),
                    ports=[ContainerPort(number=8000, name="http", protocol=Protocol.TCP)],                   
                    liveness=Probe.from_http_get(path="/healthz/live", port=8000, initial_delay_seconds=Duration.seconds(5)),
                    readiness=Probe.from_http_get(path="/healthz/ready", port=8000, initial_delay_seconds=Duration.seconds(5)),
                    security_context=ContainerSecurityContextProps(group=1000, user=1000, read_only_root_filesystem=False),
                    env_variables=env_vars,
                )
            ],
        )
        

        # Create a service
        service = deployment.expose_via_service(
            ports=[ServicePort(name="http", port=8000, target_port=8000, protocol=Protocol.TCP)],
            service_type=ServiceType.CLUSTER_IP,
            )
        #service.metadata.add_annotation("namespace", ns+"-customer")


        
        #Create an ingress
        ingress = Ingress(
            namespace, "ingress", 
            metadata=ApiObjectMetadata(namespace=namespace.name),
            )
        ingress.add_host_rule(host, "/", IngressBackend.from_service(service), HttpIngressPathType.PREFIX)
        ingress.metadata.add_annotation("nginx.ingress.kubernetes.io/ssl-redirect", "true")
        ingress.metadata.add_annotation("nginx.ingress.kubernetes.io/ssl-services", "greetings")
        ingress.metadata.add_annotation("nginx.ingress.kubernetes.io/force-ssl-redirect", "true")
        ingress.metadata.add_annotation("kubernetes.io/ingress.class", "nginx")
        
        # # Create an HPA
        hpa = HorizontalPodAutoscaler(namespace, "hpa",
                                      metadata=ApiObjectMetadata(namespace=namespace.name),
                                      target=deployment,
                                      min_replicas=1,
                                      max_replicas=3,
                                      metrics=[Metric.resource_cpu(MetricTarget.average_utilization(80))]
        )

app = App()
GreetingsApp(app, "a")
GreetingsApp(app, "b")
GreetingsApp(app, "c")
app.synth()
