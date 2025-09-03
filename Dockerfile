FROM golang:1.25 AS BUILDER

RUN git clone https://github.com/hashicorp/terraform.git \
    && cd terraform \
    && git fetch --all --tags --prune \
    && git checkout tags/v1.13.1 -b FIX-CVE-2025-8959 \
    && git config --global user.email "itops@4data.ch" \
    && git config --global user.name "itops" \
    && sed -i -e 's/go-getter v1.7.8/go-getter v1.7.9/g' go.mod \
    && go mod tidy \
	&& bash -c "export XC_ARCH=amd64; export XC_OS=linux; ./scripts/build.sh"

FROM alpine:3.22.1

ARG CDKTF_VERSION='0.21.0'
ARG TF_VERSION='1.13.1'
ARG PYTHON_VERSION='3.12.2'
ARG PYENV_HOME=/root/.pyenv

LABEL author="4Data AG"
LABEL maintainer="4Data AG"
LABEL name="python-cdktf-cli"
LABEL version=${CDKTF_VERSION}


RUN apk add --no-cache \
			npm \
			curl \
			git \
			bash \
		&& apk add --virtual temp_dep \
			libffi-dev \
			openssl-dev \
			bzip2-dev \
			zlib-dev \
			readline-dev \
			sqlite-dev \
			build-base \
			&& git clone --depth 1 https://github.com/pyenv/pyenv.git $PYENV_HOME && \
					rm -rfv $PYENV_HOME/.git \
			&& export PATH=$PYENV_HOME/shims:$PYENV_HOME/bin:$PATH \
			&& pyenv install $PYTHON_VERSION \
			&& pyenv global $PYTHON_VERSION \
			&& pip install --upgrade pip && pyenv rehash \
		&& apk del temp_dep

ENV PATH $PYENV_HOME/shims:$PYENV_HOME/bin:$PATH

RUN npm install --global cdktf-cli@${CDKTF_VERSION} \
	&& pip3 install --no-cache-dir -U pipenv

COPY --from=BUILDER /go/bin/terraform /usr/local/bin/terraform

COPY src src

WORKDIR /src

RUN pipenv install

CMD [ "cdktf" ]