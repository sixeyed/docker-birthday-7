FROM mcr.microsoft.com/azure-cli:2.0.80

ENTRYPOINT ["/bin/bash"]
CMD ["/setup.sh"]

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/

# helm
ENV DESIRED_VERSION='v3.0.3'
RUN apk --no-cache update && \
    apk --no-cache add jq openssl && \ 
    curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sh

COPY setup.sh /

ENV AKS_KUBERNETES_VERSION='1.15.5' \
    AKS_NODE_COUNT='2' \
    AKS_NODE_SIZE='Standard_DS1_v2'