FROM nvidia/cuda:9.0-cudnn7-devel

# Installs necessary dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
         wget \
         curl \
     git \
         python3-dev && \
     rm -rf /var/lib/apt/lists/*

# Installs pip.
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    pip install setuptools && \
    rm get-pip.py

WORKDIR /root
ENV FORCE_CUDA=1
RUN apt-get update
RUN apt-get install -y gcc 

# RUN conda update conda
#RUN conda update -n base -c defaults conda
#RUN  conda install cython

# RUN  conda init
# RUN source /root/.bashrc
# RUN conda create --name masktextspotter -y
# RUN conda activate masktextspotter


RUN pip install ninja yacs cython matplotlib tqdm opencv-python shapely scipy tensorboardX google-cloud-storage cloudml-hypertune torch==1.2 torchvision flask gevent
RUN apt-get -y install cmake gcc

# install pycocotools
RUN git clone https://github.com/cocodataset/cocoapi.git
WORKDIR cocoapi/PythonAPI
RUN python3 setup.py build_ext install
WORKDIR ../../

RUN apt install -y libsm6 \
libglib2.0-0 \
libxrender-dev \
libxext6 \
libgl1-mesa-glx \
wget

RUN wget "https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl"
RUN chmod +x gdown.pl

# clone repo
RUN ./gdown.pl https://drive.google.com/file/d/14Z28qrhFAk5c6LxdVUCuZ0MVNctoIDkJ/view repo.tar.xz
RUN tar -xvf repo.tar.xz
RUN rm repo.tar.xz
WORKDIR MaskTextSpotter
# build
RUN python3 setup.py build develop

CMD bash -ic "python3 main_api_batch.py"