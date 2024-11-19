#
# Dockerfile
#
#

FROM ubuntu:22.04

LABEL project="Landslides rapid mapping" \
      author="Federico Filipponi" \
      maintainer="federico.filipponi@gmail.com" \
      image_name="LandslidesDetector" \
      version="0.1" \
      released="2024-01-16" \
      software_versions="Ubuntu 22.04 with GDAL 3.4.1" \
      description="Landslides detector"

USER root

# set graphical mode
ENV TERM xterm
ENV DISPLAY :1.0

# Set default locale
# ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# Set default timezone
ENV TZ UTC

# set environenmental variables
ENV EDITOR='nano'

# install all dependencies
RUN apt update -qq && DEBIAN_FRONTEND=noninteractive apt install -yq \
        apt-utils \
        apt-transport-https \
        dialog \
        build-essential \
        gcc-multilib \
        gnupg \
        software-properties-common \
        ca-certificates \
        dirmngr \
        sudo \
        nano \
        bc \
        coreutils \
        ca-certificates \
        wget \
        libudunits2-dev \
        python3 \
        python3-pip \
        libgdal-dev \
        python3-gdal \
        binutils \
        libproj-dev \
        libgeos-dev \
        gdal-bin \
        libgdal-dev
        
# set Python3 as default
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN alias python=python3
# RUN pip install gdal pyproj gdal-utils

# install R
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -yq \
    r-base \
    r-base-dev

# install R libraries
RUN R --vanilla -e 'install.packages(c("optparse"), dependencies=c("Depends", "Imports", "LinkingTo", "Enhances"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("sf"), dependencies=c("Depends", "Imports", "LinkingTo", "Enhances"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("ncdf4"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("terra"), dependencies=c("Depends", "Imports", "LinkingTo", "Enhances"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("exactextractr"), dependencies=c("Depends", "Imports", "LinkingTo", "Enhances"), type="source", repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("cli","tibble","RcppArmadillo"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("landscapemetrics"), dependencies=c("Depends"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("doFuture"), dependencies=c("Depends", "Imports", "LinkingTo", "Enhances"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'
RUN R --vanilla -e 'install.packages(c("progressr"), dependencies=c("Depends", "Imports"), repos="http://cran.us.r-project.org", lib="/usr/lib/R/site-library")'

# remove old packages
RUN apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# create local folder for data storage
RUN mkdir -p /space/scripts
RUN chmod -R 755 /space/scripts
RUN mkdir -p /shared
RUN chmod -R 755 /shared

# extend path
ENV PATH="${PATH}:/space/scripts"

CMD /bin/bash
