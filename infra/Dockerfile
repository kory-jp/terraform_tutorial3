FROM python:3.13

ARG awscli_version="2.18.3"

# 前提パッケージのインストール
RUN apt-get update && apt-get install -y less vim curl unzip sudo

# aws cli v2 のインストール
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install

# install sam
RUN pip install --user --upgrade aws-sam-cli
ENV PATH $PATH:/root/.local/bin

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip

# install terraform.
RUN wget https://releases.hashicorp.com/terraform/1.9.7/terraform_1.9.7_linux_amd64.zip && \
  unzip ./terraform_1.9.7_linux_amd64.zip -d /usr/local/bin/

# create workspace.
COPY ./src /root/src

# initialize command.
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

COPY ./.aws /root/.aws
COPY ./init.sh /root/init.sh
RUN chmod +x /root/init.sh && /root/init.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

WORKDIR /root/src
