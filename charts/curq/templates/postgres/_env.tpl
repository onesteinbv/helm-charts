{{- define "curq.postgresEnv" -}}
- name: POSTGRES_DB
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.auth.existingSecret.name | default (printf "%s-postgres" (include "curq.fullname" .)) }}
      key: {{ .Values.postgres.auth.existingSecret.usernameKey | default "username" }}
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.auth.existingSecret.name | default (printf "%s-postgres" (include "curq.fullname" .)) }}
      key: {{ .Values.postgres.auth.existingSecret.usernameKey | default "username" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.auth.existingSecret.name | default (printf "%s-postgres" (include "curq.fullname" .)) }}
      key: {{ .Values.postgres.auth.existingSecret.passwordKey | default "password" }}
- name: LC_COLLATE
  value: "en_US.UTF-8"
- name: PGDATA
  value: "/var/lib/postgresql/data/pgdata"
{{- if .Values.postgres.extraEnv }}
{{- toYaml .Values.postgres.extraEnv }}
{{- end }}

{{- end }}