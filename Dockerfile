ARG CUDA_VER=11.8.0
ARG UBUNTU_VER=22.04
# Download the base image
FROM nvidia/cuda:${CUDA_VER}-cudnn8-runtime-ubuntu${UBUNTU_VER}

# Install as root
USER root

# Shell
SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

# miniconda path
ENV CONDA_DIR /opt/miniconda

# conda path
ENV PATH=${CONDA_DIR}/bin:$PATH

ARG DEBIAN_FRONTEND="noninteractive"
ARG USERNAME=coder
ARG USERID=1000
ARG GROUPID=1000

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bash-completion \
    ca-certificates \
    curl \
    git \
    htop \
    nano \
    nvidia-modprobe \
    nvtop \
    openssh-client \
    sudo \
    tmux \
    unzip \
    vim \
    wget \ 
    zip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install zellij
RUN curl -L -o zellij.tar.gz https://github.com/zellij-org/zellij/releases/download/v0.40.1/zellij-x86_64-unknown-linux-musl.tar.gz && \
    tar -xzf zellij.tar.gz -C /usr/local/bin && \
    rm zellij.tar.gz && \
    zellij --version

# Install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p ${CONDA_DIR} && \
    rm -rf miniconda.sh && \
    # Enable conda autocomplete
    sudo wget --quiet https://github.com/tartansandal/conda-bash-completion/raw/master/conda -P /etc/bash_completion.d/

# Add a user `${USERNAME}` so that you're not developing as the `root` user
RUN groupadd -g ${GROUPID} ${USERNAME} && \
    useradd ${USERNAME} \
    --create-home \
    --uid ${USERID} \
    --gid ${GROUPID} \
    --shell=/bin/bash && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd && \
    chown -R ${USERID}:${GROUPID} ${CONDA_DIR} && \
    echo ". $CONDA_DIR/etc/profile.d/conda.sh" >>/home/${USERNAME}/.profile

USER ${USERNAME}

WORKDIR /home/${USERNAME}

# Initilize shell for conda
RUN conda init bash && source /home/${USERNAME}/.bashrc

COPY environment.yaml /home/${USERNAME}/environment.yaml

RUN conda env create -f /home/${USERNAME}/environment.yaml
RUN conda activate Anomalydiffusion
RUN python -m pip install git+https://github.com/openai/CLIP.git@dcba3cb2e2827b402d2701e7e1c7d9fed8a20ef1
RUN python -m pip install git+https://github.com/CompVis/taming-transformers.git@3ba01b241669f5ade541ce990f7650a3b8f65318

ENTRYPOINT [ "bash" ]