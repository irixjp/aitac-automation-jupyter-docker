FROM centos:8

LABEL maintainer "@irix_jp"

ENV JP_CONF_PATH /jupyter/.jupyter

RUN dnf update -y && \
    dnf install -y glibc-all-langpacks gcc make rpm-build git sudo which tree && \
    dnf module install -y python36:3.6/common && \
    dnf module install -y python36:3.6/build && \
    dnf module install -y nodejs:10/common && \
    alternatives --set python /usr/bin/python3 && \
    dnf clean all

RUN pip3 install -U pip setuptools && \
    pip install ansible ansible-lint yamllint boto boto3 awscli && \
    pip install jupyterlab bash_kernel ansible-kernel && \
    python -m bash_kernel.install && \
    python -m ansible_kernel.install

RUN jupyter labextension install -y @jupyterlab/toc

RUN useradd jupyter -m -d /jupyter
USER jupyter
WORKDIR /jupyter

COPY --chown=jupyter:jupyter assets/.jupyter /jupyter/.jupyter
COPY --chown=jupyter:jupyter assets/.ansible.cfg /jupyter/.ansible.cfg

RUN openssl req -x509 -nodes -newkey rsa:2048 \
    -subj '/C=JP/ST=Tokyo/L=Tokyo/O=Example Ltd./OU=Web/CN=localhost' \
    -days 36500 \
    -keyout ${JP_CONF_PATH:?}/mycert.key \
    -out    ${JP_CONF_PATH:?}/mycert.pem

RUN mkdir -p /notebooks && \
    echo "alias ls='ls --color'" >> /jupyter/.bashrc  && \
    echo "alias ll='ls -alF --color'" >> /jupyter/.bashrc

EXPOSE 8888
CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--port", "8888", "--no-browser", "--certfile", "/jupyter/.jupyter/mycert.pem", "--keyfile", "/jupyter/.jupyter/mycert.key"]
