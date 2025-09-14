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
git clone https://github.com/G-Structure/free-ngrok
```

cd into the repo
```
cd free-ngrok
```

In GitHub Actions workflows, obtain the OIDC token and set it in `frpc.toml` or pass as env var.

Example workflow step:

```yaml
- name: Get OIDC token
  id: token
  run: |
    curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
         "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=https://github.com/G-Structure" \
         -o token.json
    TOKEN=$(jq -r '.value' token.json)
    echo "token=$TOKEN" >> $GITHUB_OUTPUT

- name: Run FRP client
  run: |
    sed -i 's|# auth.oidc.token|auth.oidc.token = "'${{ steps.token.outputs.token }}'"|' frpc.toml
    frpc -c frpc.toml
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
sudo nixos-rebuild  switch --flake 'github:G-Structure/free-ngrok#reverse-proxy-gcp' --refresh
```
