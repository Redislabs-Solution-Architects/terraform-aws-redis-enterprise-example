# Terraform AWS Redis Enterprise Starter

Create a Redis Enterprise Cluster from scratch on AWS using Terraform.
Redis Enterprise Cluster of 3+ nodes accessible via FQDN, username, and password.

Cluster creation options to create either Redis on RAM, Redis on Flash, and or Rack Zone Aware cluster.


## Terraform Modules to provision the following:
* New VPC 
* Any number of Redis Enterprise nodes and install Redis Enterprise software 
* DNS (NS and A records for Redis Enterprise nodes)
* Create and Join Redis Enterprise cluster
    * cluster creation options: redis on ram, redis on flash, and or rack zone awareness

### !!!! Requirements !!!
* Redis Enterprise Software 
* R53 DNS_hosted_zone_id *(if you do not have one already, set up a domain name on Route53)*
* aws access key and secret key
* an **AWS generated** SSH key for the region you are creating the cluster
    - *you must chmod 400 the key before use*

### Prerequisites
* aws-cli (aws access key and secret key)
* terraform installed on local machine
* ansible installed on local machine

#### Prerequisites (detailed instructions)
1.  Install `aws-cli` on your local machine and run `aws configure` ([link](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)) to set your access and secret key.
    - If using an aws-cli profile other than `default`, update the `aws_profile` variable to reflect the correct `aws-cli` profile.
2.  Download the `terraform` binary for your operating system ([link](https://www.terraform.io/downloads.html)), and make sure the binary is in your `PATH` environment variable.
    - MacOSX users:
        - (if you see an error saying something about security settings follow these instructions), ([link](https://github.com/hashicorp/terraform/issues/23033))
        - Just control click the terraform unix executable and click open. 
    - *you can also follow these instructions to install terraform* ([link](https://learn.hashicorp.com/tutorials/terraform/install-cli))
 3.  Install `ansible` via `pip3 install ansible` to your local machine.
     - A terraform local-exec provisioner is used to invoke a local executable and run the ansible playbooks, so ansible must be installed on your local machine and the path needs to be updated.
     - example steps:

    ```
    # create virtual environment
    python3 -m venv ./venv
    source ./venv/bin/activate
    # Check if you have pip
    python3 -m pip -V
    # Install ansible and check if it is in path
    python3 -m pip install --user ansible
    # check if ansible is installed:
    ansible --version
    # If it tells you the path needs to be updated, update it
    echo $PATH
    export PATH=$PATH:/path/to/directory
    # example: export PATH=$PATH:/Users/username/Library/Python/3.8/bin
    # (*make sure you choose the correct python version you are using*)
    # you can check if its in the path of your directory by typing "ansible-playbook" and seeing if the command exists
    ```

* (*for more information on how to install ansible to your local machine:*) ([link](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))

## Getting Started:
Now that you have terraform and ansible installed you can get started provisioning your RE cluster on AWS using terraform modules.

Since creating a Redis Enterprise cluster from scratch takes many components (VPC, DNS, Nodes, and creating the cluster via REST API) it is best to break these up into indivual `terraform modules`. That way if a user already has a pre-existing VPC, they can utilize their existing VPC instead of creating a brand new one.

There are two important files to understand. `modules.tf` and `terraform.tfvars.example`.
* `modules.tf` contains the following: 
    - `vpc module` (creates new VPC)
    - `node module` (creates and provisions vms with RE software installed)
    - `dns module` (creates R53 DNS with NS record and A records), 
    - `create-cluster module` (uses ansible to create and join the RE cluster via REST API)
    - `create-database module` (uses ansible to create databases based on configuration via REST API)
    * *the individual modules can contains inputs from previously generated from run modules.*
    - example:
    ```
    # either use the variables filled in from `.tfvars` as seen below
    module "vpc" {
    source             = "./modules/vpc"
    aws_creds          = var.aws_creds
    owner              = var.owner
    region             = var.region
    base_name          = var.base_name
    vpc_cidr           = var.vpc_cidr
    subnet_cidr_blocks = var.subnet_cidr_blocks
    subnet_azs         = var.subnet_azs
    }

    # or enter in your own values:
    module "vpc" {
    source             = "./modules/vpc"
    aws_creds          = ["accessxxxx","secretxxxxxx"]
    owner              = "redisuser"
    region             = "us-west-2"
    base_name          = "redis-user-tf"
    vpc_cidr           = "10.0.0.0/16"
    subnet_cidr_blocks = ["10.0.0.0/24","10.0.16.0/24","10.0.32.0/24"]
    subnet_azs         = ["us-west-2a","us-west-2b","us-west-2c"]
    }
    ```
* `terraform.tfvars.example`:
    - An example of a terraform variable managment file. The variables in this file are utilized as inputs into the module file. You can choose to use these or hardcode your own inputs in the modules file.
    - to use this file you need to change it from `terraform.tfvars.example` to simply `terraform.tfvars` then enter in your own inputs.

### Instructions for Use:
1. Copy the variables template. or rename it `terraform.tfvars`
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
2. Update `terraform.tfvars` variable inputs with your own inputs
    - Some require user input, some will use a default value if none is given
3. Now you are ready to go!
    * Open a terminal in VS Code:
    ```bash
    # create virtual environment
    python3 -m venv ./venv
    source ./venv/bin/activate
    # ensure ansible is in path
    ansible --version
    # run terraform commands
    terraform init
    terraform plan
    terraform apply
    # Enter a value: yes
    # can take around 10 minutes to provision cluster
    ```
4. After a successful run there should be outputs showing the FQDN of your RE cluster and the username and password. (*you may need to scroll up a little*)
 - example output:
 ```
 Outputs:
dns-ns-record-name = "https://redis-tf-us-west-2-cluster.mydomain.com"
grafana_password = "secret"
grafana_url = "http://100.20.72.136:3000"
grafana_username = "admin"
re-cluster-password = "admin"
re-cluster-url = "https://redis-tf-us-west-2-cluster.mydomain.com:8443"
re-cluster-username = "admin@admin.com"

 ```

### Changing the AMI / OS

By default an Amazon Linux 2 AMI will be used.  It is possible to change the AMI being used but it should be done in combination with a few other related variables.  Let's look at the defaults for these related variables:

```
 re_ami_name = "amzn2-ami-amd-hvm-2.0.20220606.1-x86_64-gp2"
 re_ami_owner = "137112412989"
 os_family = "al2"
 ssh_user = "ec2-user"
 re_download_url = "https://s3.amazonaws.com/redis-enterprise-software-downloads/7.4.2/redislabs-7.4.2-129-amzn2-x86_64.tar"
```

The AMI name (`re_ami_name`) along with the AMI owner (`re_ami_owner`) is provided first.  During creation of the VMs that will be used for the Redis Enterprise nodes the AMI id is looked up using these two values.  Then you need to specify the OS family which needs to match the OS of the AMI.  There are currently three options: *al2*, *rhel* or *ubuntu*. Then, you need to provide the default SSH user (`ssh_user`) for accessing the system during provisioning. Typically in the Ubuntu AMIs this is *ubuntu* while in Amazon Linux 2 (and Cent OS Stream 9) this is *ec2-user*. You will want to be sure this is correctly, otherwise the provisioning will not work.  Lastly, you need to provide a URL (`re_download_url`) for downloading the Redis Enterprise package that matches the OS.

### Creating Databases 

By default, the provisioning of database is disabled.  You don't need to use this to create databases.  Just to clarify, this can't really be for 'managing' databases. Meaning, it doesn't track the state of databases or databases configurations. This will just create databases for initial use.

Enable initial database creation:

`re_databases_create = true`

Then, you need to set the databases JSON file.  This is the default:

`re_databases_json_file = "./re_databases.json"`

This is designed to be able to use the sample databases JSON.  You can copy the `re_databases.json.example` to `re_databases.json` and then change or add the configurations you want for your databases.  The JSON is an array of database objects (https://redis.io/docs/latest/operate/rs/references/rest-api/objects/bdb/).  Each database will be created using the REST API.


## Cleanup

Remove the resources that were created.

```bash
  terraform destroy
  # Enter a value: yes
```