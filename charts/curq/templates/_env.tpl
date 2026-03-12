{{- define "curq.env" -}}

{{/* Database configuration */}}
{{- if .Values.externalPostgres.enabled }}
- name: "DB_HOST"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgres.secret.name | quote }}
      key: {{ .Values.externalPostgres.secret.hostKey | quote }}
- name: "DB_PORT"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgres.secret.name | quote }}
      key: {{ .Values.externalPostgres.secret.portKey | quote }}
{{- else if .Values.postgres.enabled }}
- name: "DB_HOST"
  value: {{ include "curq.fullname" . }}-postgres
- name: "DB_PORT"
  value: "5432"
{{- end }}
- name: "DB_USER"
  value: {{ .Values.database.role.name }}
{{- if .Values.database.role.existingSecret }}
- name: "DB_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.database.role.existingSecret }}
      key: {{ .Values.database.role.existingSecretKey }}
{{- else }}
- name: "DB_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ include "curq.fullname" . }}-role
      key: password
{{- end }}

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

{{/* Mail configuration */}}
{{/* Uses the mailcow configuration if host is not set, otherwise uses the provided configuration */}}

{{- if .Values.outgoingMail.enabled }}
{{/* Outgoing mail configuration */}}
{{- if .Values.outgoingMail.enabled }}
- name: "SETUP_SMTP"
  value: "true"
{{- if .Values.outgoingMail.host }}
- name: "SMTP_HOST"
  value: {{ .Values.outgoingMail.host | quote }}
- name: "SMTP_PORT"
  value: {{ .Values.outgoingMail.port | quote }}
- name: "SMTP_ENCRYPTION"
  value: {{ .Values.outgoingMail.encryption | quote }}
- name: "SMTP_USER"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.outgoingMail.secret.name | quote }}
      key: {{ .Values.outgoingMail.secret.usernameKey | quote }}
- name: "SMTP_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.outgoingMail.secret.name | quote }}
      key: {{ .Values.outgoingMail.secret.passwordKey | quote }}
{{- else if .Values.mailcow.enabled }}
- name: "SMTP_HOST"
  value: {{ .Values.mailcow.endpoint | quote }}
- name: "SMTP_PORT"
  value: "465"
- name: "SMTP_ENCRYPTION"
  value: "starttls"
- name: "SMTP_USER"
  value: {{ printf "catchall@%s" .Values.mailcow.domain | quote }}
- name: "SMTP_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mailcow.catchallSecret.name | default (printf "%s-catchall" (include "curq.fullname" .)) }}
      key: {{ .Values.mailcow.catchallSecret.key | quote }}
{{- else }}
{{ fail "Outgoing mail is enabled but no configuration is provided" }}
{{- end }}

{{/* Incoming mail configuration */}}
{{- if .Values.incomingMail.enabled }}
- name: "SETUP_INCOMING_MAIL"
  value: "true"
- name: "INCOMING_MAIL_CONFIRM"
  value: {{ .Values.incomingMail.confirm | quote }}
{{- if .Values.incomingMail.host }}
- name: "INCOMING_MAIL_SERVER"
  value: {{ .Values.incomingMail.host | quote }}
- name: "INCOMING_MAIL_PORT"
  value: {{ .Values.incomingMail.port | quote }}
- name: "INCOMING_MAIL_SERVER_TYPE"
  value: {{ .Values.incomingMail.type | quote }}
- name: "INCOMING_MAIL_SSL"
  value: {{ .Values.incomingMail.ssl | quote }}
- name: "INCOMING_MAIL_USER"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.incomingMail.secret.name | quote }}
      key: {{ .Values.incomingMail.secret.usernameKey | quote }}
- name: "INCOMING_MAIL_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.incomingMail.secret.name | quote }}
      key: {{ .Values.incomingMail.secret.passwordKey | quote }}
{{- else if .Values.mailcow.enabled }}
- name: "INCOMING_MAIL_SERVER"
  value: {{ .Values.mailcow.endpoint | quote }}
- name: "INCOMING_MAIL_PORT"
  value: "993"
- name: "INCOMING_MAIL_SERVER_TYPE"
  value: "imap"
- name: "INCOMING_MAIL_SSL"
  value: "true"
- name: "INCOMING_MAIL_USER"
  value: {{ printf "catchall@%s" .Values.mailcow.domain | quote }}
- name: "INCOMING_MAIL_PASSWORD"
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mailcow.catchallSecret.name | default (printf "%s-catchall" (include "curq.fullname" .)) }}
      key: {{ .Values.mailcow.catchallSecret.key | quote }}
{{- else }}
{{ fail "Incoming mail is enabled but no configuration is provided" }}
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

{{/* Keycloak configuration */}}
{{- if .Values.keycloak.enabled }}
{{- $secretName = .Values.keycloak.clientSecret.name | default (printf "%s-keycloak-client" (include "curq.fullname" .)) -}}
- name: "KEYCLOAK_URL"
  value: {{ .Values.keycloak.endpoint | quote }}
- name: "KEYCLOAK_REALM"
  value: {{ .Values.keycloak.realm | quote }}
- name: "KEYCLOAK_CLIENT_ID"
  value: {{ .Values.keycloak.clientId | default (include "curq.fullname.namespaced" .) | quote }}
- name: "KEYCLOAK_CLIENT_SECRET"
  valueFrom:
    secretKeyRef:
      name: {{ $secretName | quote }}
      key: {{ .Values.keycloak.clientSecret.key | quote }}
{{- end }}

{{/* Add additional configuration for Odoo */}}
{{- if or .Values.additionalConfig .Values.serverEnvironmentConfiguration }}
- name: "ADDITIONAL_ODOO_RC"
  value: |
{{ range $item := .Values.serverEnvironmentConfiguration }}
{{ printf "[%s]" $item.name | nindent 4 }}
{{- range $k, $v := $item.values }}
{{ printf "%s = %s" $k $v | nindent 4 }}
{{- end }}
{{- end }}
{{ .Values.additionalConfig | nindent 4 }}
{{- end }}

{{- if .Values.extraEnv }}
{{- toYaml .Values.extraEnv }}
{{- end }}
{{- end }}