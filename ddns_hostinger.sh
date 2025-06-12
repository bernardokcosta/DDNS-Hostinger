#!/bin/bash

# --- CONFIGURAÇÕES ---
DOMINIO="DOMINIO.COM"
SUBDOMINIO="SUBDOMINIO"
API_KEY="CHAVE_DE_API"
LOG_FILE="/var/log/ddns_update.log"
# --- FIM DAS CONFIGURAÇÕES ---

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

IP_ATUAL=$(curl -s https://api.ipify.org)
if [ -z "$IP_ATUAL" ]; then
    log "ERRO: Falha ao obter o IP público atual. O script será encerrado."
    exit 1
fi

IP_DNS=$(dig +short ${SUBDOMINIO}.${DOMINIO})
if [ "$IP_ATUAL" = "$IP_DNS" ]; then
    exit 0
fi

log "IP alterado. Antigo: ${IP_DNS:-'não encontrado'}. Novo: $IP_ATUAL. Iniciando atualização..."

API_ENDPOINT="https://api.hostinger.com/api/dns/v1/zones/${DOMINIO}"
RECORDS_JSON=$(curl -s -X GET "$API_ENDPOINT" -H "Authorization: Bearer ${API_KEY}")

if ! echo "$RECORDS_JSON" | jq -e '.records' > /dev/null; then
    log "ERRO: Falha ao obter os registros DNS da Hostinger. Resposta: $RECORDS_JSON"
    exit 1
fi

PAYLOAD=$(echo "$RECORDS_JSON" | jq --arg name "$SUBDOMINIO" --arg ip "$IP_ATUAL" \
    '(.records[] | select(.type == "A" and .name == $name) | .content) |= $ip')

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$API_ENDPOINT" \
-H "Authorization: Bearer ${API_KEY}" \
-H "Content-Type: application/json" \
-d "$PAYLOAD")

if [ "$HTTP_STATUS" -eq 204 ]; then
    log "SUCESSO: O DNS para ${SUBDOMINIO}.${DOMINIO} foi atualizado para $IP_ATUAL."
else
    log "ERRO: Falha ao atualizar o DNS. A API da Hostinger retornou o status HTTP $HTTP_STATUS."
    exit 1
fi

exit 0
