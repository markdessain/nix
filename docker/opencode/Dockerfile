FROM ubuntu

RUN apt-get update
RUN apt install -y curl unzip
RUN curl -fsSL https://opencode.ai/install | bash

RUN curl -OL https://golang.org/dl/go1.23.3.linux-arm64.tar.gz && tar -C /usr/local -xvf go1.23.3.linux-arm64.tar.gz

RUN mv /usr/local/go /usr/local/golang
RUN echo '#!/bin/bash\nGOCACHE=$(pwd)/.cache GOMODCACHE=$(pwd)/.cache /usr/local/golang/bin/go $@' > /usr/local/go && chmod +x /usr/local/go

ENV PATH=$PATH:/usr/local

ENTRYPOINT ["/root/.opencode/bin/opencode"]
