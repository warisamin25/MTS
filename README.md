# MTS
### To build the Dockerfile
docker build -t mts .
### To run the Dockerfile
docker run --gpus all --ipc=host -p 8001:8001 mts:lastest
### Curl Request
curl -X POST http://localhost:8001/infer  -H 'content-type: multipart/form-data'  -F files=@img_1.jpg -F files=@img_2.jpg -F files=@img_3.jpg -F files=@img_4.jpg
