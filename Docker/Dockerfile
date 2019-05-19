FROM      debian:buster
MAINTAINER Julien Manteau 


##### GLOBALS #####

# Variables
ENV VIRTUSER nsm

###### DEBIAN ###########


# Install general tools
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y tshark snort
RUN apt-get install -yq sudo wget gawk git nano vim grep coreutils
RUN apt-get install -yq lsof htop tcpdump
RUN apt-get install -yq argus-client argus-server librrds-perl
RUN apt-get install -yq bro


# User configuration
RUN adduser --disabled-password --gecos "" $VIRTUSER

# Passwords
RUN echo "$VIRTUSER:$VIRTUSER" | chpasswd
RUN echo "root:nsm" | chpasswd

# Sudo
RUN usermod -aG sudo $VIRTUSER

# Environment
WORKDIR /home/$VIRTUSER
USER nsm



