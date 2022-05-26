FROM ubuntu:18.04

# Use New Zealand mirrors
RUN sed -i 's/archive/nz.archive/' /etc/apt/sources.list

RUN apt update

# Set timezone to Auckland
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y locales tzdata git
RUN locale-gen en_NZ.UTF-8
RUN dpkg-reconfigure locales
RUN echo "Pacific/Auckland" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ:en

# Create user 'kaimahi' to create a home directory
RUN useradd kaimahi
RUN mkdir -p /home/kaimahi/
RUN chown -R kaimahi:kaimahi /home/kaimahi
ENV HOME /home/kaimahi

# Install apt packages
RUN apt update
RUN apt install -y awscli curl software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa

# Install python
ENV PYTHON_VERSION 3.9
ENV PYTHON python${PYTHON_VERSION}
ENV PIP ${PYTHON} -m pip
RUN apt update
RUN apt install -y ${PYTHON}-dev ${PYTHON}-distutils

# Set default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/${PYTHON} 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/${PYTHON} 1
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | ${PYTHON}

RUN pip3 install --upgrade pip
COPY requirements.txt /root/requirements.txt
RUN pip3 install -r /root/requirements.txt

# Install local package
COPY pkg /code/pkg
COPY setup.py /code
RUN python${PYTHON_VERSION} -m pip install -e /code
ENV PYTHONPATH="/code:${PYTHONPATH}"
