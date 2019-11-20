# MTS
## Without Docker
#### Clone the repository
$ git clone https://github.com/FortressIQ/MTS.git

$ cd MTS
#### Install all the requirements
$ sh install.sh
#### Switch to CPU inference
$ git checkout cpu
#### Build the repository
$ python3 setup.py build develop
#### Run the api using
$ python3 main_api_batch.py

## Curl Request
curl -X POST http://localhost:8001/infer  -H 'content-type: multipart/form-data'  -F files=@img_1.jpg -F files=@img_2.jpg -F files=@img_3.jpg -F files=@img_4.jpg

## Inference result
You can check the inference output in the **outputs/finetune/inference/icdar_2015_test** directory

## To build the Dockerfile
docker build -t mts .
#### To run the Dockerfile
docker run --gpus all --ipc=host -p 8001:8001 mts:lastest

#### Note:
Current batch size is set to **2**.
You can change it [here](https://github.com/FortressIQ/MTS/blob/bf888d5f08c8f306819f146124f7bc90d8bbe6e2/configs/finetune.yaml#L73).
