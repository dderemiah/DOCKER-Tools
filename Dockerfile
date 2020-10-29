FROM ubuntu:18.04
LABEL Maintainer = "danderemiah@gmail.com"

# Variable Definition
ENV ANSIBLE_VERSION "2.9.11"
ENV DEBIAN_FRONTEND=noninteractive
ENV PACKER_VERSION "1.6.4"
ENV TERRAFORM_VERSION "0.13.5"
ENV POWERSHELL_VERSION "7.0.3"

# Creating Home Directory
WORKDIR /home/danield
RUN mkdir -p /home/danield/ansible
RUN mkdir -p /home/danield/code
RUN mkdir -p /home/danield/lab-images

# Copy requirement file (PIP Libraries)
COPY requirements.txt /home/danield/requirements.txt

# Copy Ansible Config
COPY Ansible/ansible.cfg /etc/ansible/ansible.cfg

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

#install and source ansible
RUN  sed -i -e "s#us.archive.ubuntu.com#ala-mirror.wrs.com/mirror/ubuntu.com#" \
  -e "s#archive.ubuntu.com#ala-mirror.wrs.com/mirror/ubuntu.com#" \
  -e "s#security.ubuntu.com#ala-mirror.wrs.com/mirror/ubuntu.com#" \
  -e '/deb-src/d' /etc/apt/sources.list && \
  apt-get -y update && \
  apt-get -y dist-upgrade && \
  apt-get -y install \
  apt-utils \
  build-essential \
  ca-certificates \
  curl \
  dnsutils \
  fping \
  git \
  hping3 \
  htop \
  httpie \
  iftop \
  # need to expose Port
  iperf \
  iperf3 \
	ipmitool \
  iproute2 \
  iputils-arping \
  iputils-clockdiff \
  iputils-ping \
  iputils-tracepath \
  libfontconfig \
  liblttng-ust0 \
  man \
  mtr \
  mysql-client \
  mysql-server \
  nano \
  net-tools \
  #net-snmp \
  netcat \
  netperf \
  ngrep \
  nload \
  nmap \
  openssh-client \
  openssh-server \
  openssl \
  packer \
  p0f \
  python-pip \
  python-scapy \
  python3-dev \
  python3-distutils \
  python3-pip \
  python3-scapy \
  python3.7 \
  python3.8 \
  rsync \
  snmp \
  snmp-mibs-downloader \
  snmpd \
  socat \
  software-properties-common \
  speedtest-cli \
  #sysctl \
  openssh-server \
  sshpass \
  supervisor \
  sudo \
  tcpdump \
  tcptraceroute \
  telnet \
	tmux \
  traceroute \
  tshark \
  unzip \
  wget \
  vim \
  wget \
  tree \
  zsh \
  zsh-syntax-highlighting

# Install Powershell
RUN wget https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell_${POWERSHELL_VERSION}-1.ubuntu.18.04_amd64.deb
RUN dpkg -i powershell_${POWERSHELL_VERSION}-1.ubuntu.18.04_amd64.deb
RUN rm powershell_${POWERSHELL_VERSION}-1.ubuntu.18.04_amd64.deb

# Install PowerCLI
#RUN pwsh -Command Install-Module VMware.PowerCLI -Force -Verbose
RUN pwsh  -Command Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -Verbose
RUN pwsh  -Command Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:\$false


# Install Oh-My-ZSH
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# Install Packer
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip
RUN mv packer /usr/local/bin

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

# Install Pip requirements
RUN pip3 install -q --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install -q ansible==$ANSIBLE_VERSION
RUN pip3 install -r requirements.txt
RUN pip3 install pyATS[library]

# Add user danield
RUN useradd -u845 -ms /bin/zsh danield
RUN usermod -a -G sudo,danield danield
# add to sudoers
COPY system/sudoers /etc/sudoers
RUN chown root:root /etc/sudoers && chmod 0440 /etc/sudoers

# Copy Oh-My_ZSH Setting
COPY .zshrc /home/danield/.zshrc
ADD .oh-my-zsh /home/danield/.oh-my-zsh
RUN  chown -R danield:danield /home/danield
#RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
#RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Install OVF Tools
COPY system/ovftools/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle /home/danield/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle
RUN /bin/bash /home/danield/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle --eulas-agreed --required --console

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf requirements.txt
RUN rm packer_${PACKER_VERSION}_linux_amd64.zip
RUN rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN rm VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle
