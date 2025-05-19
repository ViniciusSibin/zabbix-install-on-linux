#!/bin/bash

set -e  # Sai ao primeiro erro

echo "🔍 Detectando sistema operacional..."

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        OS_VERSION="$VERSION_ID"
    else
        echo "❌ Não foi possível detectar o sistema operacional."
        exit 1
    fi
    echo "🖥️  Detected: $OS_NAME $OS_VERSION"
}

install_on_debian_like() {
    echo "Solicitando permissão de superusuário..."
    if [ "$EUID" -ne 0 ]; then
        echo "🔑 Você não é root. Executando como sudo..."
        sudo "$0" "$@"
        exit
    fi
    echo "🔑 Você é root. Continuando..."

    echo "📦 Atualizando pacotes (apt)..."
    apt update -y

    echo "📥 Instalando dependências do Zabbix..."

    apt install -y wget gnupg2 build-essential snmpd snmp snmptrapd libsnmp-base libsnmp-dev htop vim apache2 apache2-utils lsb-release apt-transport-https ca-certificates software-properties-common ; wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg ; sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' ; apt update ; apt install -y php ; apt install -y libapache2-mod-php php-mysql php-cli php-pear php-gmp php-gd php-bcmath php-curl php-xml php-zip python3-pip

    #configure_zabbix_repo_debian
    #install_database_debian
    #install_zabbix_server_debian
}

install_on_rhel_like() {
    echo "📦 Atualizando pacotes (yum)..."
    yum update -y

    echo "📥 Instalando dependências do Zabbix..."
    yum install -y wget epel-release

    configure_zabbix_repo_rhel
    install_database_rhel
    install_zabbix_server_rhel
}

# Funções específicas para Debian/Ubuntu
configure_zabbix_repo_debian() {
    echo "🔧 Configurando repositório Zabbix (Debian)..."
    wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian$(lsb_release -rs)_all.deb
    dpkg -i zabbix-release_*.deb
    apt update -y
}

install_database_debian() {
    echo "🗄️ Instalando MariaDB (Debian)..."
    apt install -y mariadb-server mariadb-client
    systemctl enable mariadb
    systemctl start mariadb
}

install_zabbix_server_debian() {
    echo "🖥️ Instalando Zabbix Server (Debian)..."
    apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
}

# Funções específicas para CentOS/RHEL/Rocky
configure_zabbix_repo_rhel() {
    echo "🔧 Configurando repositório Zabbix (RHEL)..."
    rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-6.4-1.el$(rpm -E %{rhel}).noarch.rpm
    dnf clean all
}

install_database_rhel() {
    echo "🗄️ Instalando MariaDB (RHEL)..."
    yum install -y mariadb-server
    systemctl enable mariadb
    systemctl start mariadb
}

install_zabbix_server_rhel() {
    echo "🖥️ Instalando Zabbix Server (RHEL)..."
    yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent
}

# EXECUÇÃO
detect_os

case "$OS_NAME" in
    ubuntu|debian)
        install_on_debian_like
        ;;
    centos|rhel|rocky)
        install_on_rhel_like
        ;;
    *)
        echo "❌ Sistema operacional $OS_NAME não suportado ainda."
        exit 1
        ;;
esac

echo "✅ Instalação base concluída. Configure o banco e inicie os serviços manualmente ou adicione ao script."
