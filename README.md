Project for Security of computer systems class  

## Files

check_officer_app.sh - checks officer_app.c correctness  
client_project - Django project with client app  
initial_setup.sh - creates users directories and sets permissions  
install.sh - installs required stuff  
ssh_setup.sh - sets officer_app.c to run after connecting via ssh  
run_client_and_officer_app.sh - runs client app and ssh  
nftables.conf - firewall rules  


## Usage

```bash
docker build -t bank_app_image .
```

```bash
docker run --name bank_container -p 2022:22 -p 8000:8000 -i -t bank_app_image
```

ssh
```bash
ssh officer@127.0.0.1 -p 2022
```

client app link - http://0.0.0.0:8000  

passwd - password for all users
