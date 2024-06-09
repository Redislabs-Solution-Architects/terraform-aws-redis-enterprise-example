#### Provider variables
variable "region" {
    description = "AWS region"
}

variable "aws_creds" {
    description = "Access key and Secret key for AWS [Access Keys, Secret Key]"
}

#### Important variables
variable "ssh_key_name" {
    description = "name of ssh key to be added to instance"
}

variable "ssh_key_path" {
    description = "name of ssh key to be added to instance"
}

variable "owner" {
    description = "owner tag name"
}

#### VPC
variable "base_name" {
    description = "base name for resources"
    default = "redisuser1-tf"
}

variable "vpc_cidr" {
    description = "vpc-cidr"
    default = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
    type = list(any)
    description = "subnet_cidr_block"
    default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "subnet_azs" {
    type = list(any)
    description = "subnet availability zone"
    default = [""]
}

#### DNS
variable "dns_hosted_zone_id" {
    description = "DNS hosted zone Id"
}


#### Redis Enterprise Cluster Variables
variable "re_download_url" {
  description = "re download url"
  default     = "https://s3.amazonaws.com/redis-enterprise-software-downloads/7.4.2/redislabs-7.4.2-129-amzn2-x86_64.tar"
}

variable "flash_enabled" {
  description = "Redis on Flash cluster"
  default     = false
}

variable "rack_awareness" {
  description = "Rack zone aware cluster"
  default     = false
}

variable "re_license" {
  description = "Redis Enterprise license"
  default     = ""
}
variable "data-node-count" {
  description = "number of data nodes"
  default     = 3
}

variable "ena-support" {
  description = "choose AMIs that have ENA support enabled"
  default     = true
}

variable "node-prefix-re" {
  description = "node prefix"
  default     = "re"
}

variable "re_instance_type" {
    description = "re instance type"
    default     = "t2.xlarge"
}

variable "node-root-size" {
  description = "The size of the root volume"
  default     = "50"
}

#### EBS volume for persistent and ephemeral storage
variable "create_ebs_volumes_re" {
  description = "Whether to create EBS volume or not"
  type        = bool
  default     = true
}


#### EBS volume for persistent and ephemeral storage
variable "re-volume-size" {
  description = "The size of the ephemeral and persistent volumes to attach"
  default     = "150"
}

#### Security
variable "open-nets" {
  type        = list(any)
  description = "CIDRs that will have access to everything"
  default     = []
}

variable "allow-public-ssh" {
  description = "Allow SSH to be open to the public - enabled by default"
  default     = "1"
}

variable "internal-rules" {
  description = "Security rules to allow for connectivity within the VPC"
  type        = list(any)
  default = [
    {
      type      = "ingress"
      from_port = "22"
      to_port   = "22"
      protocol  = "tcp"
      comment   = "SSH from VPC"
    },
    {
      type      = "ingress"
      from_port = "1968"
      to_port   = "1968"
      protocol  = "tcp"
      comment   = "Proxy traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "3333"
      to_port   = "3341"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "3343"
      to_port   = "3344"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "36379"
      to_port   = "36380"
      protocol  = "tcp"
      comment   = "Cluster traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "8001"
      to_port   = "8001"
      protocol  = "tcp"
      comment   = "Traffic from application to RS Discovery Service"
    },
    {
      type      = "ingress"
      from_port = "8002"
      to_port   = "8002"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8004"
      to_port   = "8004"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8006"
      to_port   = "8006"
      protocol  = "tcp"
      comment   = "System health monitoring"
    },
    {
      type      = "ingress"
      from_port = "8443"
      to_port   = "8443"
      protocol  = "tcp"
      comment   = "Secure (HTTPS) access to the management web UI"
    },
    {
      type      = "ingress"
      from_port = "8444"
      to_port   = "8444"
      protocol  = "tcp"
      comment   = "nginx <-> cnm_http/cm traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "9080"
      to_port   = "9080"
      protocol  = "tcp"
      comment   = "nginx <-> cnm_http/cm traffic (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "9081"
      to_port   = "9081"
      protocol  = "tcp"
      comment   = "For CRDB management (Internal use)"
    },
    {
      type      = "ingress"
      from_port = "8070"
      to_port   = "8071"
      protocol  = "tcp"
      comment   = "Prometheus metrics exporter"
    },
    {
      type      = "ingress"
      from_port = "9443"
      to_port   = "9443"
      protocol  = "tcp"
      comment   = "REST API traffic, including cluster management and node bootstrap"
    },
    {
      type      = "ingress"
      from_port = "10000"
      to_port   = "19999"
      protocol  = "tcp"
      comment   = "Database traffic - if manually creating db ports pare down"
    },
    {
      type      = "ingress"
      from_port = "20000"
      to_port   = "29999"
      protocol  = "tcp"
      comment   = "Database shards traffic - if manually creating db ports pare down"
    },
    {
      type      = "ingress"
      from_port = "53"
      to_port   = "53"
      protocol  = "udp"
      comment   = "DNS Traffic"
    },
    {
      type      = "ingress"
      from_port = "5353"
      to_port   = "5353"
      protocol  = "udp"
      comment   = "DNS Traffic"
    },
    {
      type      = "ingress"
      from_port = "-1"
      to_port   = "-1"
      protocol  = "icmp"
      comment   = "Ping for connectivity checks between nodes"
    },
    {
      type      = "egress"
      from_port = "-1"
      to_port   = "-1"
      protocol  = "icmp"
      comment   = "Ping for connectivity checks between nodes"
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "tcp"
      comment   = "Let TCP out to the VPC"
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "udp"
      comment   = "Let UDP out to the VPC"
    }
    
  ]
}

variable "external-rules" {
  description = "Security rules to allow for connectivity external to the VPC"
  type        = list(any)
  default = [
    {
      type      = "ingress"
      from_port = "53"
      to_port   = "53"
      protocol  = "udp"
      cidr      = ["0.0.0.0/0"]
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "tcp"
      cidr      = ["0.0.0.0/0"]
    },
    {
      type      = "egress"
      from_port = "0"
      to_port   = "65535"
      protocol  = "udp"
      cidr      = ["0.0.0.0/0"]
    }
    
  ]
}

#### update envoy concurrency settings to work around a bug in envoy

variable "update_envoy_concurrency" {
  type = bool
  default = false
}

variable "envoy_concurrency_setting" {
  type = number
  default = 2
}



####### Node Output Variables
#### used in additional modules

variable "vpc_security_group_ids" {
    type = list
    description = "."
    default = []
}

variable "os_family" {
  description =  "Operating system family: ubuntu, rhel, or al2"
  type = string
  default = "al2"
  validation {
    condition = contains(["ubuntu", "al2", "rhel"], var.os_family)
    error_message = "Must be either \"ubuntu\", \"al2\" or \"rhel\"."
  }
}

variable "re_ami_name" {
    description = "AMI name to use for nodes. "
    default = "amzn2-ami-amd-hvm-2.0.20220606.1-x86_64-gp2"
}

variable "re_ami_owner" {
    description = "AMI Owner"
    default = "137112412989"
}

variable "ssh_user" {
  description = "The default username to connect to the nodes.  The default AMI is AL2 so it will be set to ec2-user. If ubuntu AMI is being used change to 'ubuntu'"
  default = "ec2-user"
}

####### Create Cluster Variables
####### Node and DNS outputs used to Create Cluster
variable "dns_fqdn" {
    description = "."
    default = ""
}

variable "re-node-internal-ips" {
    type = list
    description = "."
    default = []
}

variable "re-node-eip-ips" {
    type = list
    description = "."
    default = []
}

variable "re-data-node-eip-public-dns" {
    type = list
    description = "."
    default = []
}

############# Create RE Cluster Variables

#### Cluster Inputs
#### RE Cluster Username
variable "re_cluster_username" {
    description = "redis enterprise cluster username"
    default     = "admin@admin.com"
}

#### RE Cluster Password
variable "re_cluster_password" {
    description = "redis enterprise cluster password"
    default     = "admin"
}

############# Create RE Databases

#### Create databases flag
variable "re_databases_create" {
  description = "Create databases"
  default     = false
}

variable "re_databases_json_file" {
    description = "Array of database objects to create using the RE REST API. Required if re_create_databases is set. (warning: no check if database already exists)"
    default = "./re_databases.json"
}