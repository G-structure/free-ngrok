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

install `frp`

```
nix profile install nixpkgs#frp
```

clone this repo 
```
git clone https://github.com/r33drichards/free-ngrok
```

cd into the repo 
```
cd free-ngrok
```

edit the `frpc.toml` in the project root to include the client secret from [our keycloak instance](https://kc.flakery.xyz/admin/master/console/#/frp/clients/a9f346a4-92d0-4fe9-9994-7cb8adea3a63/credentials) 

```toml
# ..
auth.oidc.clientSecret = "3VCK5Lz964Z1LWWs3TJmkg4peBHsQDET"  # Replace with your actual client secret
# ..
```

run the client to create a tunnel 

```
frpc -c frpc.toml
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
