{{/*
Expand the name of the chart.
*/}}
{{- define "odoo-upgrader.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "odoo-upgrader.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "odoo-upgrader.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "odoo-upgrader.labels" -}}
helm.sh/chart: {{ include "odoo-upgrader.chart" . }}
{{ include "odoo-upgrader.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "odoo-upgrader.selectorLabels" -}}
app.kubernetes.io/name: {{ include "odoo-upgrader.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "odoo-upgrader.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "odoo-upgrader.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* 
Postgresql connection url
*/}}
{{- define "odoo-upgrader.dbUrl" -}}
{{- if .Values.odooUpgrader.dbUrl }}
{{- .Values.odooUpgrader.dbUrl }}
{{- else if .Values.postgresql.enabled }}
{{- $db := include "odoo-upgrader.fullname" . }}
{{- $postgres := printf "%s-%s" $db "postgres" }}
{{- printf "postgresql://%s:%s@%s:5432/%s" .Values.postgresql.auth.username .Values.postgresql.auth.password $postgres $db }}
{{- else if .Values.odooUpgrader.persistence.enabled }}
sqlite:////data/app.db
{{- else }}
sqlite:///app.db
{{- end }}
{{- end }}