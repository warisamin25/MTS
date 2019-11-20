wget "https://raw.githubusercontent.com/circulosmeos/gdown.pl/master/gdown.pl"
chmod +x gdown.pl
./gdown.pl https://drive.google.com/file/d/1pPRS7qS_K1keXjSye0kksqhvoyD0SARz/view model_finetune.pth
mkdir -p datasets/icdar2015/test_images
mkdir -p outputs/finetune
mv model_finetune.pth outputs/finetune
pip3 install -r requirements.txt -f https://download.pytorch.org/whl/torch_stable.html

