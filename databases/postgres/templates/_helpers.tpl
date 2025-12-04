{{/*
Common labels for all resources
*/}}
{{- define "postgres.labels" -}}
app: {{ .Values.name }}
app.kubernetes.io/name: {{ .Values.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.tag | quote }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: dockify
app.kubernetes.io/managed-by: dockify
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgres.selectorLabels" -}}
app: {{ .Values.name }}
app.kubernetes.io/name: {{ .Values.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Full name helper
*/}}
{{- define "postgres.fullname" -}}
{{- .Values.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Secret name
*/}}
{{- define "postgres.secretName" -}}
{{ include "postgres.fullname" . }}-secret
{{- end }}
