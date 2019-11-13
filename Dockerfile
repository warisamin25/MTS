FROM pytorch/pytorch:1.2-cuda10.0-cudnn7-devel
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

RUN pip install ninja yacs cython matplotlib tqdm opencv-python shapely scipy tensorboardX google-cloud-storage cloudml-hypertune flask gevent
RUN apt-get -y install cmake gcc

# install pycocotools
RUN git clone https://github.com/cocodataset/cocoapi.git
WORKDIR cocoapi/PythonAPI
RUN python setup.py build_ext install
WORKDIR ../../

RUN apt install -y libsm6 \
libglib2.0-0 \
libxrender-dev \
libxext6 \
libgl1-mesa-glx \
wget

RUN wget "https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl"
RUN chmod +rwx gdown.pl

# clone repo
RUN ./gdown.pl https://drive.google.com/file/d/14Z28qrhFAk5c6LxdVUCuZ0MVNctoIDkJ/view repo.tar.xz
RUN tar -xvf repo.tar.xz
RUN rm repo.tar.xz
WORKDIR MaskTextSpotter
# build
RUN python setup.py build develop
EXPOSE 8001
ENTRYPOINT ["python", "main_api_batch.py"]