FROM ubuntu:25.10

ARG CDKTF_VERSION='0.21.0'
ARG TF_VERSION='1.12.2'
ARG PYTHON_VERSION='3.12.2'
ARG PYENV_HOME=/home/ubuntu/.pyenv
ARG NPM_VERSION='11.6.0'

LABEL author="4Data AG"
LABEL maintainer="4Data AG"
LABEL name="python-cdktf-cli"



RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests jq yq curl git bash sudo zip unzip make ca-certificates \
    && apt-get clean \
    && apt-get remove --purge nodejs npm \
    && curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash - \
    && apt-get install -y --no-install-recommends --no-install-suggests nodejs


RUN usermod -a -G root ubuntu \
    && usermod -a -G sudo ubuntu \
    && usermod -g root ubuntu \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


USER ubuntu

WORKDIR /home/ubuntu

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv \
    && export PYENV_ROOT="$HOME/.pyenv" \
    && export PATH="$PYENV_ROOT/bin:$PATH" \
    && sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends --no-install-suggests build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    && sudo apt-get clean

ENV PATH $PYENV_HOME/shims:$PYENV_HOME/bin:$PATH

RUN pyenv install $PYTHON_VERSION \
		&& pyenv global $PYTHON_VERSION \
		&& pip install --upgrade pip && pyenv rehash

RUN curl -fsSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
  && unzip /tmp/terraform.zip -d /tmp \
  && sudo mv /tmp/terraform /usr/local/bin/ \
  && rm -rf /tmp/*

RUN sudo npm install -g npm@${NPM_VERSION} \
    && sudo npm install --global cdktf-cli@${CDKTF_VERSION} \
	&& pip3 install --no-cache-dir -U pipenv \
    && sudo deluser ubuntu sudo

WORKDIR /src

COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock

RUN pipenv install