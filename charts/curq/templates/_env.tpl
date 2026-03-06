{{- define "curq.env" -}}

{{/* Database configuration */}}
- name: "DB_HOST"
  value: ""
- name: "DB_PORT"
  value: ""
- name: "DB_PASSWORD"
  value: ""

{{/* Force no crons and workers when installing or updating */}}
{{- if or (eq .mode "install") (eq .mode "update") }}
- name: "MAX_CRON_THREADS"
  value: "0"
- name: "WORKERS"
  value: "0"
{{- end }}

{{/* Database manager configuration */}}
{{- if .Values.databaseManager.enabled }}
- name: "LIST_DB"
  value: "True"
- name: "DB_FILTER"
  value: {{ .Values.databaseManager.filter | quote }}
{{- else }}
- name: "LIST_DB"
  value: "False"
- name: "DB_FILTER"
  value: {{ printf "^%s$" (.Values.database.name | quote) }}
{{- end }}

{{- if .Values.databaseManager.existingSecret }}
- name: "ADMIN_PASSWD"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.databaseManager.existingSecret | quote }}
      key: {{ .Values.databaseManager.existingSecretKey | quote }}
{{- else }}
- name: "ADMIN_PASSWD"
  valueFrom:
    secretKeyRef:
      name: {{ include "curq.fullname" . }}-db-manager
      key: "password"
{{- end }}

{{/* Only do this when we want to initialize a database */}}
{{- if .Values.database.name }}
{{- $modules := .Values.modules | default (list "base") }}
- name: "DB_NAME"
  value: {{ .Values.database.name | quote }}
- name: "MODULES"
  value: {{ join "," $modules }}
- name: "DOMAIN"
  value: {{ .Values.domain | quote }}
- name: "UNINSTALL_MODULES"
  value: {{ .Values.uninstallModules | quote }}

{{/* Outgoing mail configuration */}}
{{- if .Values.outgoingMail.enabled }}
- name: "SETUP_SMTP"
  value: "true"
{{- end }}

{{/* Incoming mail configuration */}}
{{- if .Values.incomingMail.enabled }}
- name: "SETUP_INCOMING_MAIL"
  value: "true"
- name: "INCOMING_MAIL_CONFIRM"
  value: {{ .Values.incomingMail.confirm | quote }}
{{- end }}

{{/* Company configuration */}}
- name: "UPDATE_COMPANY"
  value: {{ .Values.company.update | quote }}
- name: "COMPANY_NAME"
  value: {{ .Values.company.name | quote }}
- name: "COMPANY_EMAIL"
  value: {{ .Values.company.email | quote }}
- name: "COMPANY_COC"
  value: {{ .Values.company.coc | quote }}
- name: "COMPANY_CITY"
  value: {{ .Values.company.city | quote }}
- name: "COMPANY_ZIP"
  value: {{ .Values.company.zip | quote }}
- name: "COMPANY_STREET"
  value: {{ .Values.company.street | quote }}

{{/* User configuration */}}
{{- if .Values.user.update }}
- name: "PREPARE_CUSTOMER_USER"
  value: "true"
- name: "USER_EMAIL"
  value: {{ .Values.user.email | quote }}
{{- end }}
{{- end }}

{{/* Add additional configuration for Odoo */}}
{{- if .Values.additionalConfig }}
- name: "ADDITIONAL_ODOO_RC"
  value: |
{{ .Values.additionalConfig | nindent 4 }}
{{- end }}


{{- end }}