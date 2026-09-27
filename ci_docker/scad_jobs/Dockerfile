FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update -qq
RUN apt-get -o DPkg::Options::=--force-confdef -y -qq install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates python3-pip python-is-python3 git xvfb imagemagick unzip inkscape wget
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/o/openscad/openscad_2021.01-4build1_amd64.deb -O /tmp/openscad_2021.01-4build1_amd64.deb
RUN apt -o DPkg::Options::=--force-confdef -y -qq install /tmp/openscad_2021.01-4build1_amd64.deb
COPY ./requirements.txt /opt/requirements.txt
WORKDIR /opt
RUN pip install -r requirements.txt