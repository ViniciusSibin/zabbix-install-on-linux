# 🚀 AutoZabbix - Instalação automática do Zabbix Server + Grafana

Automatize a instalação completa do Zabbix Server (backend, banco de dados, frontend e dashboards no Grafana) com apenas **um comando**.  
Ideal para quem quer agilidade, padronização e domínio de infraestrutura Linux.

---

## 📌 Sobre o projeto

Este script instala o stack completo de monitoramento com **Zabbix + MariaDB + Grafana** de forma **modular** e **inteligente**, detectando automaticamente a distribuição Linux e executando os comandos corretos para:

- Atualizar pacotes do sistema
- Instalar o banco de dados (MariaDB)
- Configurar repositórios do Zabbix e do Grafana
- Instalar o Zabbix Server, frontend e agente
- Instalar e configurar o Grafana
- Realizar configurações iniciais (usuários, serviços, permissões)
- Iniciar e habilitar todos os serviços no boot

Tudo isso via terminal com um único comando `curl`.

---

## 🛠️ Tecnologias e recursos utilizados

- 🐧 Shell Script (bash)
- 🧠 Detecção automática de OS
- 🧩 Estrutura modular por funções
- 💾 MariaDB / MySQL
- 📊 Zabbix Server + Frontend
- 📈 Grafana + Zabbix Plugin
- 🌐 Apache + PHP
- 🔄 Systemd

---

## ✅ Distribuições suportadas (em progresso)

- [x] Debian / Ubuntu
- [x] CentOS / RHEL / Rocky Linux
- [ ] AlmaLinux
- [ ] Fedora

---

## ⚙️ Como usar

### 1. Dê permissão no servidor do script (exemplo):
```bash
chmod +x install-zabbix.sh
```

### 2. Ou execute direto via `curl` (quando publicado em um subdomínio, FTP ou GitHub Raw):
```bash
bash <(curl -s https://seudominio.com/zabbix/install.sh)
```

---

## 📂 Estrutura do script

```text
install-zabbix.sh
├── Detecta o sistema operacional
├── Define funções específicas para cada OS
├── Executa cada etapa modularmente:
│   ├── configure_zabbix_repo
│   ├── configure_grafana_repo
│   ├── install_database
│   ├── install_zabbix_server
│   ├── install_grafana
│   ├── setup_database_schema
│   ├── configure_zabbix_frontend
│   ├── configure_grafana_plugin
│   ├── start_services
│   └── configure_firewall
```

---

## 📊 Integração com Grafana

O script instala e configura o **Grafana** automaticamente, incluindo:

- Instalação do pacote Grafana OSS
- Ativação e inicialização do serviço
- Instalação do plugin oficial `alexanderzobnin-zabbix-app`
- (Futuro) Configuração automática da fonte de dados Zabbix via API

Com isso, você terá dashboards avançados e visuais integrados com seu Zabbix Server logo após a instalação.

---

## 💡 Objetivo

Este projeto foi criado para:

- Aprimorar meu domínio de Shell Script em ambientes reais
- Automatizar tarefas repetitivas e críticas de forma segura
- Criar um ambiente de monitoramento pronto para produção em minutos
- Servir de portfólio profissional na área de infraestrutura e observabilidade

---

## 👨‍💻 Autor

**Vinicius Luiz Sibin**  
Analista de OSS | Fundador da Sibintech Monitoring  
[LinkedIn](https://www.linkedin.com/in/viniciusluizsibin)

---

## 📜 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.