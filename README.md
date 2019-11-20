# MTS
## Without Docker
#### Build the repository using
$ python3 setup.py build develop
#### Run the api using
$ python3 main_api_batch.py

## To build the Dockerfile
docker build -t mts .
#### To run the Dockerfile
docker run --gpus all --ipc=host -p 8001:8001 mts:lastest
#### Curl Request
curl -X POST http://localhost:8001/infer  -H 'content-type: multipart/form-data'  -F files=@img_1.jpg -F files=@img_2.jpg -F files=@img_3.jpg -F files=@img_4.jpg
#### Note:
Current batch size is set to 4.
You can change it [here](https://github.com/FortressIQ/MTS/blob/331418d62783cbb90ebcce5b274c605b5aaf9f94/configs/finetune.yaml#L73).
