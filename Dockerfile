FROM gitlab-registry.cern.ch/paas-tools/openshift-client

COPY ./worker.py ./rediswq.py ./enqueuePVs.sh ./backupPVs.sh /

RUN yum install epel-release -y && \
    # yum update -y && \
    # install redis
    yum install redis -y && \
    # install restic
    yum install yum-plugin-copr -y && \
    yum copr enable copart/restic -y && \
    yum install restic -y && \
    chmod +x /*.sh && \
    chmod +x /*.py 

CMD  python worker.py