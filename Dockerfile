FROM centos:7

MAINTAINER @irix_jp

RUN yum update -y && \
    yum clean all

# setup additional repo
RUN yum install -y epel-release && \
    yum install -y https://centos7.iuscommunity.org/ius-release.rpm && \
    yum clean all

# set JP locale
RUN yum reinstall -y glibc-common && \
    yum clean all && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

# install base packages
RUN yum install -y sudo git vim wget which gcc gcc-c++ unzip && \
    yum install -y python2-virtualenv python2-virtualenvwrapper && \
    yum install -y python36u python36u-libs python36u-devel python36u-pip && \
    yum clean all

# Create 'jupyter' user
ENV NB_USER jupyter
ENV NB_UID 1000
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir /home/$NB_USER/.jupyter && \
    chown -R $NB_USER:users /home/$NB_USER/.jupyter && \
    echo "$NB_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$NB_USER

## Python kernel with matplotlib, etc...
RUN pip3.6 install --upgrade pip setuptools && \
    pip3.6 install jupyter

# Copy config files
COPY conf /tmp/
USER $NB_USER
RUN mkdir -p $HOME/.jupyter && \
    cp -f /tmp/jupyter_notebook_config.py \
       $HOME/.jupyter/jupyter_notebook_config.py

### extensions for Jupyter (python3)
USER root
RUN pip3.6 install jupyter_nbextensions_configurator ipywidgets six && \
    pip3.6 install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master && \
    pip3.6 install https://github.com/NII-cloud-operation/Jupyter-LC_wrapper/tarball/master && \
    pip3.6 install https://github.com/NII-cloud-operation/Jupyter-LC_nblineage/tarball/master && \
    pip3.6 install git+https://github.com/NII-cloud-operation/Jupyter-i18n_cells.git && \
    pip3.6 install https://github.com/NII-cloud-operation/Jupyter-LC_run_through/tarball/master && \
    pip3.6 install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs && \
    pip3.6 install git+https://github.com/NII-cloud-operation/Jupyter-LC_index.git && \
    pip3.6 install bash_kernel

USER $NB_USER
RUN mkdir -p $HOME/.local/share && \
    ipython kernel install --user && \
    python3.6 -m bash_kernel.install --user && \
    jupyter contrib nbextension install --user && \
    jupyter kernelspec install /tmp/kernels/python3-wrapper --user && \
    jupyter kernelspec install /tmp/kernels/bash-wrapper --user && \
    jupyter nblineage quick-setup --user && \
    jupyter run-through quick-setup --user && \
    jupyter nbextension enable --user --py widgetsnbextension && \
    jupyter nbextension install --py nbextension_i18n_cells --user && \
    jupyter nbextension enable --py nbextension_i18n_cells --user && \
    jupyter nbextension install --py lc_multi_outputs --user && \
    jupyter nbextension enable --py lc_multi_outputs --user && \
    jupyter nbextension install --py notebook_index --user && \
    jupyter nbextension enable --py notebook_index --user

### notebooks dir
USER root
RUN mkdir -p /notebooks
COPY sample-notebooks /notebooks
RUN chown $NB_USER:users -R /notebooks
WORKDIR /notebooks

### Bash Strict Mode
RUN cp /tmp/bash_env /etc/bash_env
ENV BASH_ENV=/etc/bash_env

### nbconfig
USER $NB_USER
RUN mkdir -p $HOME/.jupyter/nbconfig && \
    cp /tmp/notebook.json $HOME/.jupyter/nbconfig/notebook.json

### Theme for jupyter
RUN mkdir -p $HOME/.jupyter/custom/ && \
    cd /tmp/ && curl -O https://fontawesome.com/v4.7.0/assets/font-awesome-4.7.0.zip && \
        unzip font-awesome-4.7.0.zip && cp -fr font-awesome-4.7.0/fonts $HOME/.jupyter/custom/ && \
    cp /tmp/custom.css $HOME/.jupyter/custom/custom.css && \
    cp /tmp/logo.png $HOME/.jupyter/custom/logo.png && \
    sed -e s,../fonts/,./fonts/,g font-awesome-4.7.0/css/font-awesome.css >> $HOME/.jupyter/custom/custom.css

## Custom get_ipython().system() to control error propagation of shell commands
RUN mkdir -p $HOME/.ipython/profile_default/startup && \
    cp /tmp/10-custom-get_ipython_system.py $HOME/.ipython/profile_default/startup/

####################
### Handson Environments
####################
USER root
RUN pip3.6 install ansible ansible-lint ansible-tower-cli boto boto3 awscli yq \
           pandas matplotlib numpy seaborn scipy scikit-learn \
           scikit-image sympy cython patsy statsmodels cloudpickle dill bokeh h5py \
           yamllint

RUN yum install -y iproute net-tools bind-utils jq openssh-server openssh-clients \
                   ipa-gothic-fonts ipa-mincho-fonts ipa-pgothic-fonts ipa-pmincho-fonts \
                   tree nano && \
    yum clean all && \
    /usr/bin/ssh-keygen -t rsa     -f /etc/ssh/ssh_host_rsa_key     -C '' -N '' && \
    /usr/bin/ssh-keygen -t ecdsa   -f /etc/ssh/ssh_host_ecdsa_key   -C '' -N '' && \
    /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''

USER $NB_USER
ENV SHELL=/bin/bash
EXPOSE 8888
CMD ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0"]
