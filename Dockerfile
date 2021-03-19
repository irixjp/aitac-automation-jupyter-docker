FROM centos:8

LABEL maintainer "@irix_jp"

ENV JP_CONF_PATH /jupyter/.jupyter

RUN dnf update -y && \
    dnf install -y glibc-all-langpacks gcc make rpm-build git sudo which tree jq autoconf automake libcurl-devel && \
    dnf install -y epel-release && dnf install -y czmq-devel && \
    dnf module install -y python36:3.6/common && \
    dnf module install -y python36:3.6/build && \
    dnf module install -y nodejs:12/common && \
    alternatives --set python /usr/bin/python3 && \
    dnf clean all

RUN pip3 install -U pip setuptools && \
    pip install ansible==2.9.19 ansible-lint yamllint boto boto3 awscli yq && \
    pip install jupyterlab bash_kernel && \
    python -m bash_kernel.install && \
    pip install mglearn matplotlib plotly scikit-learn numpy pandas openpyxl xlrd seaborn plotly xgboost tensorflow keras lightgbm pandas_datareader bs4 tqdm hyperopt tensorboard && \
    rm -rf ~/.cache/pip

RUN mkdir ~/temp && cd ~/temp && \
    git clone -b release https://github.com/roswell/roswell.git && cd roswell && \
    sh bootstrap && ./configure && make && make install && \
    cd ~/ && rm -rf ~/temp

RUN jupyter labextension install -y @jupyterlab/toc && \
    jupyter labextension install -y @jupyter-widgets/jupyterlab-manager

RUN useradd jupyter -m -d /jupyter && \
    mkdir -p /notebooks && \
    chown -R jupyter:jupyter /notebooks && \
    echo 'jupyter ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER jupyter
WORKDIR /jupyter

COPY --chown=jupyter:jupyter assets/.jupyter /jupyter/.jupyter
COPY --chown=jupyter:jupyter assets/.ansible.cfg /jupyter/.ansible.cfg

RUN ros setup && ros install sbcl --without-install && ros config set dynamic-space-size 4gb && \
    ros install common-lisp-jupyter && \
    ros -e '(require :common-lisp-jupyter)' -e '(cl-jupyter:install)'

COPY --chown=jupyter:jupyter assets/kernel.json /jupyter/.local/share/jupyter/kernels/common-lisp/kernel.json

RUN echo "alias ls='ls --color'" >> /jupyter/.bashrc  && \
    echo "alias ll='ls -alF --color'" >> /jupyter/.bashrc && \
    echo 'export PATH=$HOME/.roswell/bin:$PATH' >> /jupyter/.bashrc

EXPOSE 8888
CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--port", "8888", "--no-browser"]
