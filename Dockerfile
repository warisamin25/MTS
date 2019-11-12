FROM nvidia/cuda:10.0-base-ubuntu16.04

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda create -y --name py36 python=3.6.9 \
 && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
RUN /home/user/miniconda/bin/conda install conda-build=3.18.9=py36_3 \
 && /home/user/miniconda/bin/conda clean -ya

# CUDA 10.0-specific steps
RUN conda install -y -c pytorch \
    cudatoolkit=10.0 \
    "pytorch=1.2.0=py3.6_cuda10.0.130_cudnn7.6.2_0" \
    "torchvision=0.4.0=py36_cu100" \
 && conda clean -ya

# Install HDF5 Python bindings
RUN conda install -y h5py=2.8.0 \
 && conda clean -ya
RUN pip install h5py-cache==1.0

# Install Torchnet, a high-level framework for PyTorch
RUN pip install torchnet==0.0.4

# Install Requests, a Python library for making HTTP requests
RUN conda install -y requests=2.19.1 \
 && conda clean -ya

# Install Graphviz
RUN conda install -y graphviz=2.40.1 python-graphviz=0.8.4 \
 && conda clean -ya

# Install OpenCV3 Python bindings
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    libcanberra-gtk-module \
    python3-dev \ 
    gcc \
    libsm6 \
    libglib2.0-0 \
    libxrender-dev \
    libxext6 \
    libgl1-mesa-glx \
    wget \
 && sudo rm -rf /var/lib/apt/lists/*
RUN conda install -y -c menpo opencv3=3.1.0 \
 && conda clean -ya

RUN pip install ninja yacs cython matplotlib tqdm opencv-python shapely scipy tensorboardX google-cloud-storage

# install PyTorch
# RUN conda install pytorch==1.2.0 torchvision cudatoolkit=10.0 -c pytorch

# install pycocotools
RUN git clone https://github.com/cocodataset/cocoapi.git
WORKDIR cocoapi/PythonAPI
RUN python setup.py build_ext install
WORKDIR ../../

# clone repo
RUN git clone https://github.com/MhLiao/MaskTextSpotter.git
WORKDIR MaskTextSpotter
# build
# RUN  python setup.py build develop

# COPY outputs ./outputs
# COPY datasets ./datasets



RUN wget "https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl"
RUN chmod +x gdown.pl

RUN ./gdown.pl https://drive.google.com/file/d/13XT5S2lKtsoh5T3R9VqIH40kWrXZ5xe4/view?usp=sharing data.tar.xz
RUN tar -xvf data.tar.xz
RUN rm data.tar.xz

RUN ./gdown.pl  https://drive.google.com/open?id=1uUxveWTNVdbeXuz9zdfRdLgxZ0ueYHYN  model.tar.xz
RUN tar -xvf model.tar.xz
RUN rm model.tar.xz

COPY configs/finetune.yaml ./configs/
COPY configs/pretrain.yaml ./configs/

COPY tools/test_net.py ./tools/
COPY tools/train_net.py ./tools/

COPY key.json ./

COPY train.sh ./
COPY test.sh ./

# COPY setup.py setup.py
# COPY predictor.py predictor.py

# Set up the entry point to invoke the trainer.
# RUN python -c "import torch; print(torch.cuda.is_available())"
#ENTRYPOINT ["sh", "test.sh"]
