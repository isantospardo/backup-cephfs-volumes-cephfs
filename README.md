# Backup solution for CephFS persistent volumes

We need to backup CephFS persistent volumes. By default we do not have any automatically backup solution.

This [backup solution](https://gitlab.cern.ch/paas-tools/storage/backup-cephfs-volumes) backs up the CephFS persistent volumes filtering the volumes with label `backup-cephfs-volumes.cern.ch/backup=true`.
When a PV has this label specified, a `redis` queue is filled out with all the `json` information about the PV.
Once this process success, we process the elements of the queue  by a job. This job creates a pod per each PV `json` and mount the PV into the pod.
When the PV is mounted into the pod, the backup solution (which use [`restic`](https://restic.net/) under the hood) starts to back up each PV.

Once this PV is backed up, we add some annotations into the PV to check wether it succeeded or it failed to back up the PV.
We also created some alarms in prometheus to check if the PVs are not backed up for a long time. This makes sure everything works as expected.

To do this, we need to set several things:

- The back ups are backed up in S3
- The persistent volumes are going to be backed up once a day
- We remove the PVs in ... 
- We prune the PVs in ...

## ServiceAccounts

- Service account where the `cronjob` is running. In this case we define the service account in [CephFS SCC deployment](https://gitlab.cern.ch/paas-tools/infrastructure/cephfs-csi-deployment).
  This service account must be privileged to be able to mount volumes inside the pods created by the cronjob.

## Deployment

This backup solution for CephFS volumes is deployed with `helm` as a subchart of [CephFS csi deployment](https://gitlab.cern.ch/paas-tools/infrastructure/cephfs-csi-deployment).
The namespace used to be deployed is by default `paas-infra-backups`, in all the clusters.

We just need to create the `redis` pod and service to store the PV json elements in the queue.
```
oc create -f redis-pod.yaml -n paas-infra-backups
oc create -f redis-service.yaml -n paas-infra-backups
```