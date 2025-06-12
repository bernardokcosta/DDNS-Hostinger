# Hostinger DDNS Client Script

Um script de shell simples e seguro para atuar como um cliente de DNS Dinâmico (DDNS) para domínios hospedados na **Hostinger**.

Este script verifica periodicamente o endereço IP público de uma máquina e, caso ele tenha mudado, atualiza automaticamente o registro `A` correspondente na zona de DNS da Hostinger.

## ✨ Funcionalidades

* **Integração Nativa**: Usa a API oficial da Hostinger para atualizações.
* **Atualização Segura**: Lê todos os registros existentes antes de modificar apenas o necessário, evitando a exclusão acidental de outros registros.
* **Leve e Simples**: Requer apenas `curl`, `dig` e `jq`, ferramentas comuns em ambientes Linux.
* **Logs Inteligentes**: Registra eventos apenas quando ocorrem erros ou uma atualização de IP é bem-sucedida, evitando logs desnecessários.

***

## ⚙️ Pré-requisitos

Antes de começar, certifique-se de que sua VM (máquina virtual) possui os seguintes pacotes instalados:

* `curl`: para fazer as requisições à API.
* `jq`: para manipular os dados JSON retornados pela API.
* `bind-utils` (ou `dnsutils`): que fornece o comando `dig` para consultar o DNS.

Você pode instalá-los com o seguinte comando:

```bash
# Para Debian / Ubuntu
sudo apt-get update && sudo apt-get install -y curl jq dnsutils

# Para CentOS / RHEL / Fedora
sudo yum install -y curl jq bind-utils
```

***

## 🚀 Instalação

1.  **Clone o Repositório**
    Clone este repositório para um local de sua preferência na sua VM, como `/opt`.

    ```bash
    git clone https://github.com/bernardokcosta/DDNS-Hostinger.git /opt/hostinger-ddns
    cd /opt/hostinger-ddns
    ```

2.  **Dê Permissão de Execução**
    Torne o script executável:

    ```bash
    chmod +x ddns_hostinger.sh
    ```

***

## 🔧 Configuração

Abra o arquivo `ddns_hostinger.sh` com um editor de texto e altere as seguintes variáveis no início do script:

```bash
# --- CONFIGURAÇÕES ---
DOMINIO="DOMINIO.COM"
SUBDOMINIO="SUBDOMINIO"
API_KEY="CHAVE_DE_API"
LOG_FILE="/var/log/ddns_update.log"
# --- FIM DAS CONFIGURAÇÕES ---
```

* `DOMINIO`: Seu nome de domínio principal gerenciado na Hostinger.
* `SUBDOMINIO`: O nome do registro `A` que você deseja atualizar (ex: `vm`, `servidor`, `casa`).
* `API_KEY`: Sua chave de API da Hostinger.

## ▶️ Automação com Cron

Para que o script funcione como um serviço de DDNS, ele precisa ser executado periodicamente. Usaremos o `cron` para isso.

1.  Abra o editor de agendamento de tarefas com privilégios de administrador:

    ```bash
    sudo crontab -e
    ```

2.  Adicione a seguinte linha no final do arquivo. Ela fará com que o script seja executado a cada 5 minutos:

    ```crontab
    */5 * * * * /opt/hostinger-ddns/ddns_hostinger.sh
    ```
    
3.  Salve e feche o editor.

Você pode verificar os logs para ver se tudo está funcionando corretamente:

```bash
tail -f /var/log/ddns_update.log
```

***
