# Deploy-Suricata-with-DevOps
This repository demonstrates deploying Suricata IDS with DevOps techniques by utilizing Terraform, Ansible, and KVM on  Ubuntu 20.04.

The setup guide here was fully tested on Ubuntu 20.04.

The Terraform deployment script is sensor.tf, additional configuration for Terraform deployment is cloud_init.cfg, and the Ansible playbook is playbook.yml

## Running Terraform Script

Install Terraform on Administrator system. Your laptop...

```bash
wget https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip
sudo unzip terraform_0.14.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

Install Terraform KVM provider on Ubuntu. This is installed in both the standard user and the root user's working directory because we need to run terraform with sudo permission in order to use all libvirt features.

```bash
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.0/terraform-provider-libvirt-0.6.0+git.1569597268.1c8597df.Ubuntu_18.04.amd64.tar.gz

tar xvf terraform-provider-libvirt-0.6.0+git.1569597268.1c8597df.Ubuntu_18.04.amd64.tar.gz
```

Move `terraform-provider-libvirt` binary file to the `~/.terraform.d/plugins` directory.

```
mkdir -p ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64

mv terraform-provider-libvirt ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64
```

Open cloud_init.cfg and replace the credentials with yours. This includes the username, password, and SSH key. For better security, some of the settings there can also be modified.

Run `sudo terraform plan` to plan the provisioning.

Run `sudo terraform apply` to deploy the instance.

Check the IP address of the newly created instance by running `terraform refresh`

> There is an error `Could not open '/var/lib/libvirt/images/<FILE_NAME>': Permission denied` that is thrown when we try to apply the configuration. This is a bug I know exists in Ubuntu 20.04 and to fix this, we disable security driver in the configuration file `/etc/libvirt/qemu.conf` with the string `security_driver = "none"` and restart the service `sudo systemctl restart libvirtd.service`. Then run un `sudo terraform apply` again.

## Running Ansible Playbook

Install Ansible on the Administrator system.

```
sudo apt install ansible
```

Run the Ansible playbook to deploy the tools on the new instance. Replace <instance_ip_address> with the IP address of your newly created instance. Also replace the ansible_sudo_password "chme" with any new password you specified in cloud_init.cfg file.

```
ansible-playbook -u ubuntu -i <instance_ip_address>, playbook.yml --extra-vars "ansible_sudo_pass=chme"
```

After successful deployment, Suricata should be up and running. Proceed to do additional configuration which might include setting the network interface the IDS should listen on etc.
