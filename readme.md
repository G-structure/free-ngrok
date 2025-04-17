# building gcp nixos image 

## build the image

on a linux machine, run 

```
nix build .#reverse-proxy-gcp
```

## upload to gcp bucket

```
cd result
gsutil cp nixos-image-google-compute-25.05.20250108.bffc22e-x86_64-linux.raw.tar.gz gs://nixos-amis-dialogues/
```

then create an image in gcp console using this gcp bucket object


# run the client 

```
nix run github:r33drichards/free-ngrok#reverse-proxy-client
```


# switch to configuration 

connect to instance 

```
gcloud compute ssh --zone "us-central1-c" "instance-20250327-051501" --project "dialogues-3a2cb" 
```

apply config

```
sudo nixos-rebuild  switch --flake 'github:r33drichards/free-ngrok#reverse-proxy-gcp' --refresh
```