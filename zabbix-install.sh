#!/bin/bash

set -e  # Sai ao primeiro erro

# Variáveis de configuração
ZABBIX_CONF="/etc/zabbix/zabbix_server.conf"
DB_NAME="zabbix"
DB_USER="zabbix"
DB_PASSWORD="As!b!nt&ch"

ascii_banner() {
    echo
    echo "+------------------------------------------------+"
    figlet -f small "$1"
    echo "+------------------------------------------------+"
    echo
}

ascii_banner  "Sistema operacional"

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

    ascii_banner "Atualizando pacotes"
    apt update -y ; apt upgrade -y

    ascii_banner "Dependências Zabbix"

    apt install -y wget gnupg2 build-essential snmpd snmp snmptrapd libsnmp-base libsnmp-dev htop vim apache2 apache2-utils lsb-release apt-transport-https ca-certificates software-properties-common figlet; wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg ; sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' ; apt update ; apt install -y php ; apt install -y libapache2-mod-php php-mysql php-cli php-pear php-gmp php-gd php-bcmath php-curl php-xml php-zip python3-pip

    

    install_database_debian
    configure_zabbix_repo_debian
    install_zabbix_server_debian
    #configure_zabbix_server
    #install_grafana
    #install_plugin_zabbix_on_grafana
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

install_database_debian() {
    ascii_banner "Instalando MariaDB"
    apt install -y mariadb-server mariadb-client
    systemctl enable mariadb
    systemctl start mariadb

    echo "Realizando configuração segura do MariaDB"

    mysql -u root <<EOF
        -- Remove usuários anônimos
        DELETE FROM mysql.user WHERE User='';
        -- Remove acesso remoto do root
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost');
        -- Remove banco de dados de teste
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        -- Aplica as alterações
        FLUSH PRIVILEGES;
        -- Cria o banco de dados do Zabbix
        CREATE DATABASE IF NOT EXISTS ${DB_NAME} character set utf8mb4 collate utf8mb4_bin;
        CREATE USER IF NOT EXISTS'${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${DB_USER}.* TO '${DB_USER}'@'%';
        SET GLOBAL log_bin_trust_function_creators = 1;
        FLUSH PRIVILEGES;
EOF

    echo "✅ Configuração segura do MariaDB concluída."
}

configure_zabbix_repo_debian() {
    ascii_banner "Repositorio Zabbix"
    
    cd /tmp

    wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
    
    dpkg -i zabbix-release_*.deb

    apt update -y
}

install_zabbix_server_debian() {
    ascii_banner "Instalando Zabbix"
    apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
}

configure_zabbix_server() {
    echo "🔧 Configurando Zabbix Server..."
    # Define a database name (descomenta e altera ou adiciona se não existir)
    if grep -q "^# DBName=" "$ZABBIX_CONF"; then
        sed -i "s/^# DBName=.*/DBName=$DB_NAME/" "$ZABBIX_CONF"
    elif grep -q "^DBName=" "$ZABBIX_CONF"; then
        sed -i "s/^DBName=.*/DBName=$DB_NAME/" "$ZABBIX_CONF"
    else
        echo "DBName=$DB_NAME" >> "$ZABBIX_CONF"
    fi

    # Define o usuário do banco
    if grep -q "^# DBUser=" "$ZABBIX_CONF"; then
        sed -i "s/^# DBUser=.*/DBUser=$DB_USER/" "$ZABBIX_CONF"
    elif grep -q "^DBUser=" "$ZABBIX_CONF"; then
        sed -i "s/^DBUser=.*/DBUser=$DB_USER/" "$ZABBIX_CONF"
    else
        echo "DBUser=$DB_USER" >> "$ZABBIX_CONF"
    fi

    # Define a senha do banco
    if grep -q "^# DBPassword=" "$ZABBIX_CONF"; then
        sed -i "s/^# DBPassword=.*/DBPassword=$DB_PASSWORD/" "$ZABBIX_CONF"
    elif grep -q "^DBPassword=" "$ZABBIX_CONF"; then
        sed -i "s/^DBPassword=.*/DBPassword=$DB_PASSWORD/" "$ZABBIX_CONF"
    else
        echo "DBPassword=$DB_PASSWORD" >> "$ZABBIX_CONF"
    fi
}

install_grafana() {
    echo "📥 Instalando Grafana..."
    wget https://dl.grafana.com/oss/release/grafana_9.4.7_amd64.deb
    dpkg -i grafana_9.4.7_amd64.deb
    systemctl enable grafana-server
    systemctl start grafana-server
}

install_plugin_zabbix_on_grafana() {
    echo "🔌 Instalando plugin Zabbix no Grafana..."
    grafana-cli plugins install alexanderzobnin-zabbix-app
    systemctl restart grafana-server
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
