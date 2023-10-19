{{/*
Expand the name of the chart.
*/}}
{{- define "vault-demo.name" -}}
{{- default .Chart.Name| trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vault-demo.fullname" -}}
{{- $name := default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vault-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vault-demo.labels" -}}
helm.sh/chart: {{ include "vault-demo.chart" . }}
{{ include "vault-demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vault-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vault-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "vault-demo.livenessprobe" }}
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - |
      VAULT_PATH="{{ .VAULT_PATH }}"
      VAULT_TOKEN="admin"
      VAULT_ADDRESS="http://$VAULT_DEMO_VAULT_SERVICE_HOST:$VAULT_DEMO_VAULT_SERVICE_PORT/v1/secret/data/$VAULT_PATH"
      VAULT_HEADER="X-Vault-Token: $VAULT_TOKEN"

      HTTP_STATUS_CODE=$(curl -s --location "$VAULT_ADDRESS" --header "X-Vault-Token: $VAULT_TOKEN" -o /dev/null -w "%{http_code}")
    
      if [ "$HTTP_STATUS_CODE" = "000" ]; then
        echo "Service not found on given URL: $VAULT_ADDRESS"
        exit 0
      elif [ "$HTTP_STATUS_CODE" = "404" ]; then
        echo "Route not found on given URL: $VAULT_ADDRESS"
        exit 0
      elif [ "$HTTP_STATUS_CODE" = "403" ]; then
        echo "Incorrect token: $VAULT_TOKEN for $VAULT_ADDRESS"
        exit 0
      else
        echo "Status code: $HTTP_STATUS_CODE"
        echo "$(curl -s -H "$VAULT_HEADER" "$VAULT_ADDRESS" | jq -r '.data.metadata.version')" > /tmp/liveness-version.txt
        if cmp -s /tmp/version.txt /tmp/liveness-version.txt; then 
          echo "Environment variable version $(cat /tmp/liveness-version.txt) is up to date"
          exit 0
        else
          echo "New environment variable version $(cat /tmp/liveness-version.txt) detected"
          exit 1
        fi
      fi
  initialDelaySeconds: 10
  periodSeconds: 2
{{- end -}}