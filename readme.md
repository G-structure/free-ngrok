# building gcp nixos image 

## build the image

on a linux machine, run 

```
nix build .#reverse-proxy-gcp
```

## upload to s3

```
cd result
gsutil cp nixos-image-google-compute-25.05.20250108.bffc22e-x86_64-linux.raw.tar.gz gs://nixos-amis-dialogues/
```

then create an image in gcp console using this s3 key


# run the client 

```
nix run github:r33drichards/free-ngrok#reverse-proxy-client
```