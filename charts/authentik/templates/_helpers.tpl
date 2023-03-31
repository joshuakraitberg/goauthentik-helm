{{- define "authentik.ingress.isStable" -}}
  {{- $isStable := "" -}}
  {{- if eq (include "common.capabilities.ingress.apiVersion" $) "networking.k8s.io/v1" -}}
    {{- $isStable = "true" -}}
  {{- end -}}
  {{- $isStable -}}
{{- end -}}

{{- define "authentik.env" -}}
  {{- $promoteToSecret := list
    "AUTHENTIK_SECRET_KEY"
    "AUTHENTIK_BOOTSTRAP_PASSWORD"
    "AUTHENTIK_BOOTSTRAP_TOKEN"
    "AUTHENTIK_EMAIL__PASSWORD"
    "AUTHENTIK_POSTGRESQL__PASSWORD"
    "AUTHENTIK_REDIS__PASSWORD"
  }}
  {{- range $k, $v := .values -}}
    {{- if kindIs "map" $v -}}
      {{- range $sk, $sv := $v -}}
        {{- $entry := printf "%s__%s" (upper $k) (upper $sk) }}
        {{- include "authentik.env" (dict "root" $.root "values" (dict $entry $sv)) -}}
      {{- end -}}
    {{- else -}}
      {{- $value := $v -}}
      {{- if or (kindIs "bool" $v) (kindIs "float64" $v) -}}
        {{- $v = quote $v -}}
      {{- else -}}
        {{- $v = tpl $v $.root | quote }}
      {{- end -}}
      {{- if and ($v) (ne $v "\"\"") }}
{{- $entry := printf "AUTHENTIK_%s" (upper $k)  }}
{{- if not (has $entry $promoteToSecret) }}
- name: {{ $entry }}
  value: {{ $v }}
{{- else }}
- name: {{ $entry }}
  valueFrom:
    secretKeyRef:
      name: {{ include "common.names.fullname" $.root }}
      key: {{ $entry }}
{{- end }}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "authentik.secrets" -}}
  {{- $promoteToSecret := list
    "AUTHENTIK_SECRET_KEY"
    "AUTHENTIK_BOOTSTRAP_PASSWORD"
    "AUTHENTIK_BOOTSTRAP_TOKEN"
    "AUTHENTIK_EMAIL__PASSWORD"
    "AUTHENTIK_POSTGRESQL__PASSWORD"
    "AUTHENTIK_REDIS__PASSWORD"
  }}
  {{- $secretValues := dict }}
  {{- range $k, $v := .values -}}
    {{- if kindIs "map" $v -}}
      {{- range $sk, $sv := $v -}}
        {{- $entry := printf "%s__%s" (upper $k) (upper $sk) }}
        {{- include "authentik.secrets" (dict "root" $.root "values" (dict $entry $sv)) -}}
      {{- end -}}
    {{- else -}}
      {{- $value := $v -}}
      {{- if or (kindIs "bool" $v) (kindIs "float64" $v) -}}
        {{- $v = quote $v -}}
      {{- else -}}
        {{- $v = tpl $v $.root | quote }}
      {{- end -}}
      {{- if and ($v) (ne $v "\"\"") }}
{{- $entry := printf "AUTHENTIK_%s" (upper $k)  }}
{{- if has $entry $promoteToSecret }}
{{ $entry }}: {{ $v }}
{{- end }}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end -}}
