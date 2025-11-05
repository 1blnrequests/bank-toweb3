{{- define "customer-onboarding.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "customer-onboarding.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "customer-onboarding.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "customer-onboarding.labels" -}}
helm.sh/chart: {{ include "customer-onboarding.chart" . }}
app.kubernetes.io/name: {{ include "customer-onboarding.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.podLabels }}
{{- toYaml .Values.podLabels | nindent 0 }}
{{- end }}
{{- end -}}

{{- define "customer-onboarding.selectorLabels" -}}
app.kubernetes.io/name: {{ include "customer-onboarding.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "customer-onboarding.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "customer-onboarding.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
