############################################################
# Dockerfile to build Cowrie SSH honeypot
# Based on Ubuntu
# Partly based on micheloosterhof/docker-cowrie
############################################################

# Set the base image to Ubuntu
FROM ubuntu:bionic

# File Author / Maintainer
LABEL "maintainer"="Ahmed Naveed Asif" \
      "version"="1.0"

COPY ./libgmpxx4ldbl_6.1.2+dfsg-2_amd64.deb /opt/
RUN dpkg -i /opt/libgmpxx4ldbl_6.1.2+dfsg-2_amd64.deb

# Update the repository sources list and install prerequisites
# Update the repository sources list and install prerequisites
RUN apt-get --quiet update && \
    apt-get install --assume-yes \
    git \
    python-virtualenv \
    python-setuptools \
    libmpfr-dev \
    libssl-dev \
    libmpc-dev \
    libffi-dev \
    build-essential \
    libpython-dev \
    python2.7-minimal \
    authbind \
    python-pip \
    python-twisted \
    python-configparser

# Add new non-root user
RUN groupadd -r cowrie && \
    useradd --system \
        --gid cowrie \
        --create-home \
        --shell /sbin/nologin cowrie && \
    mkdir -p /opt/cowrie

RUN chown -R cowrie:cowrie /opt/cowrie

# Switch to cowrie user
USER cowrie
WORKDIR /opt/cowrie

# Download the code from GitHub
RUN git clone http://github.com/honeyned/cowrie /opt/cowrie

# Setup Virtual Environment
RUN virtualenv cowrie-env
RUN /bin/bash -c "source cowrie-env/bin/activate"
RUN pip install -r requirements.txt
RUN exit

# Export the python path for running cowrie
RUN export PYTHONPATH=/opt/cowrie

USER cowrie
WORKDIR /opt/cowrie/log

RUN touch /opt/cowrie/log/cowrie.json
RUN touch /opt/cowrie/log/cowrie.log

VOLUME ["/opt/cowrie/etc/", "/opt/cowrie/dl/", "/opt/cowrie/log/"]

##################### INSTALLATION END #####################

# Open the port and start cowrie
EXPOSE 2222 2223

ENTRYPOINT ["/opt/cowrie/bin/cowrie", "start"]
