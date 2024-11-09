# misc/load-balance-control-plane
this is the configuration I use to load balance my kubernetes control-plane nodes for api (kubectl) access.
<br>
[this](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/) is what i'm talking about

## how
i run an nginx instance for each (physical) node in my homelab with the configuration provided in this folder.
<br>
each instance has an upstream containing the ips of the vms i'm running the control plane components on, effectively load balancing connections between them.
<br>
i use `keepalived` to "unify" each nginx instance under a single virtual-ip by aggregating arp queries.
<br>
what i did, essentialy, was to create a container running keepalived and nginx (i use proxmox) on each physical node. one container will be elected leader (using the .main.conf file), while all the others will be backup nodes: if the leader goes down, another container will take its place and will start to serve requests in its place. i know this is not true load balancing, but it has a pretty decent failover time and it satisfies my homelabbing needs.
<br>
the leader container will listen for ARP queries for the configured virtual ip (in this case `11.11.11.253`, which is the ip i want to load balance) and will reply with its mac address, so that the requests will be sent there (that's how keepalived essentialy works).
