FROM cs50/cli

# Image metadata
LABEL maintainer="CS50 <sysadmins@cs50.harvard.edu>"
LABEL version="0.0.1"
LABEL description="CS50 IDE (Online) image."

ARG DEBIAN_FRONTEND=noninteractive

# Expose port 22 for Cloud9 SSH environment connection
EXPOSE 22

RUN mkdir --parent /home/ubuntu/.ssh &&  \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3enFD6CibqsRHazKUbxf1GMP6adwxI7F0x3r9PegNQbKg7eQCH2Nao6Ypuv3OvTvMIzlpsEcnunQh8pHq6A4uDyf6xCOOhTB3+Asv8LofVm8xzGYRTOfdxJCJCP6z5veHc52u2uNtsjRAEvMw5Uyvf/FAoPj7kSaYVBNSLOZo5tgoLaS2o9YzeOcc4c+ADdCTUKqpWuZ79WAGczTna8POIJsupDnxhL15uvk65QLzaSpOk17GNux8MCgfjRt8MN1yPWEhMvkpi5bSjXsmfed1pTkvtC2JH5YknhKIDXPTLLtNG+T0pndFIeFPLxsdbgAK9yHAFX6T3/h/S0hByiyuo+r/5iw4ap8VPkTXjtmPq+nZjhW4fx7eClLVGF8WYLtW1L5XJzPqV8VvUphvJD+8xffdq7JnGJsrHVOtrrd6jNmOOatBM9yhg+0KwsQC/6gk58T0T7b7ePEsWxTRo63GAwjtaqwijSz7f+sTHAnuAlgTdq4gyr0ulhuegzJLWogXgn7xXr2M8oEjAed3oEKfNJoNVoS6qh67uvoc9wQz2ApPDM2ZiIgy2qcIKPD+sIb2nz+yJYnnVMaw18OpswH7hq43XMfoA9WPAHdlKUrO/y1DFcpvWutBsbckm+WoCdkHIKgDw4af7AU29eCkcpPpzFVxqmJT/aNZ7boz6FlqHQ== kzidane+265111720517@cloud9.amazon.com" > /home/ubuntu/.ssh/authorized_keys 

# Install apt packages
RUN sudo apt-get update --quiet && \
    sudo apt-get install --yes \
        openssh-server \
        php-xdebug && \
    sudo mkdir /var/run/sshd `# required by openssh-server`

# Install ngrok client
RUN wget --directory-prefix /tmp https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
    sudo unzip -d /usr/local/bin /tmp/ngrok-stable-linux-amd64.zip && \
    sudo chmod a+x /usr/local/bin/ngrok

# Download and install Cloud9 SSH installer
RUN curl --silent --location https://raw.githubusercontent.com/c9/install/master/install.sh > /tmp/c9install && \
    chmod a+x /tmp/c9install && \
    sudo mkdir /opt/c9 && \
    sudo chown --recursive ubuntu:ubuntu /opt/c9 && \
    sed --in-place 's#C9_DIR=.*#C9_DIR=/opt/c9#' /tmp/c9install && \
    /tmp/c9install

# Install Python packages
RUN pip3 install \
        nltk \
        plotly \
        pylint \
        pylint_django \
        pylint_flask \
        twython && \
    sudo python3 -m nltk.downloader -d /usr/share/nltk_data/ punkt

# Add courses group
RUN sudo groupadd --system courses

# Add cs50 user
RUN sudo adduser --gecos "CS50,,,," --ingroup courses --disabled-login --system cs50

# Symlink .c9 files and start openssh daemon
CMD mkdir --parent /home/ubuntu/.c9 && \
    ln --symbolic --force /opt/c9/* /home/ubuntu/.c9 && \
    sudo chown --recursive ubuntu:ubuntu /home/ubuntu && \
    sudo /usr/sbin/sshd -D