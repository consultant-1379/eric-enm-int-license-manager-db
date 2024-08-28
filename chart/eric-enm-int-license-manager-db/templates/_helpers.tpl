{{/* vim: set filetype=mustache: */}}

{{/*
Create a map from "Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-enm-int-license-manager-db.global" }}
{{- $globalDefaults := dict "nodeSelector" (dict) -}}
{{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent")) -}}
{{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
{{- $globalDefaults := merge $globalDefaults (dict "pullSecret") -}}
{{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
{{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}

{{ if .Values.global }}
 {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
{{ else }}
 {{- $globalDefaults | toJson -}}
{{ end }}
{{ end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enm-int-license-manager-db.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-enm-int-license-manager-db.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Service account plain name
*/}}
{{- define "eric-enm-int-license-manager-db.serviceAccountPlainName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eric-enm-int-license-manager-db.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

 {{/*
 Create the name of the service account
 */}}
 {{- define "eric-enm-int-license-manager-db.serviceAccountName" -}}
 {{- print (include "eric-enm-int-license-manager-db.serviceAccountPlainName" .) -}}
 {{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-enm-int-license-manager-db.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-enm-int-license-manager-db.licenseManagerDb.registryUrl" -}}
{{- if (and .Values.global .Values.global.registry .Values.global.registry.url) -}}
{{- print .Values.global.registry.url -}}
{{- else if (and .Values.imageCredentials .Values.imageCredentials.licenseManagerDb .Values.imageCredentials.licenseManagerDb.registry .Values.imageCredentials.licenseManagerDb.registry.url) -}}
{{- print .Values.imageCredentials.licenseManagerDb.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{- define "eric-enm-int-license-manager-db.licenseManagerDbWait.registryUrl" -}}
{{- if (and .Values.global .Values.global.registry .Values.global.registry.url) -}}
{{- print .Values.global.registry.url -}}
{{- else if (and .Values.imageCredentials .Values.imageCredentials.licenseManagerDbWait .Values.imageCredentials.licenseManagerDbWait.registry .Values.imageCredentials.licenseManagerDbWait.registry.url) -}}
{{- print .Values.imageCredentials.licenseManagerDbWait.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image repo path
*/}}
{{- define "eric-enm-int-license-manager-db.licenseManagerDb.repoPath" -}}
{{- if (and .Values.global .Values.global.registry .Values.global.registry.repoPath) -}}
{{- print .Values.global.registry.repoPath -}}
{{- else if (and .Values.imageCredentials .Values.imageCredentials.licenseManagerDb .Values.imageCredentials.licenseManagerDb.repoPath) -}}
{{- print .Values.imageCredentials.licenseManagerDb.repoPath -}}
{{- else -}}
{{- print .Values.imageCredentials.repoPath -}}
{{- end -}}
{{- end -}}

{{- define "eric-enm-int-license-manager-db.licenseManagerDbWait.repoPath" -}}
{{- if (and .Values.global .Values.global.registry .Values.global.registry.repoPath) -}}
{{- print .Values.global.registry.repoPath -}}
{{- else if (and .Values.imageCredentials .Values.imageCredentials.licenseManagerDbWait .Values.imageCredentials.licenseManagerDbWait.repoPath) -}}
{{- print .Values.imageCredentials.licenseManagerDbWait.repoPath -}}
{{- else -}}
{{- print .Values.imageCredentials.repoPath -}}
{{- end -}}
{{- end -}}

{{/*
Create imagePullPolicies
*/}}
{{- define "eric-enm-int-license-manager-db.licenseManagerDb.imagePullPolicy" -}}
{{- $g := fromJson (include "eric-enm-int-license-manager-db.global" .) }}
{{- print  (or .Values.imageCredentials.licenseManagerDb.registry.imagePullPolicy $g.registry.imagePullPolicy) -}}
{{- end -}}

{{- define "eric-enm-int-license-manager-db.licenseManagerDbWait.imagePullPolicy" -}}
{{- $g := fromJson (include "eric-enm-int-license-manager-db.global" .) }}
{{- print  (or .Values.imageCredentials.licenseManagerDbWait.registry.imagePullPolicy $g.registry.imagePullPolicy) -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enm-int-license-manager-db.pullSecrets" -}}
{{- if (and .Values.global .Values.global.pullSecret) -}}
{{- print .Values.global.pullSecret -}}
{{- else if .Values.imageCredentials.pullSecret -}}
{{- print .Values.imageCredentials.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create replicas
*/}}
{{- define "eric-enm-int-license-manager-db.replicas" -}}
{{- if index .Values "global" "replicas-eric-enm-int-license-manager-db" -}}
{{- print (index .Values "global" "replicas-eric-enm-int-license-manager-db") -}}
{{- else if index .Values "replicas-eric-enm-int-license-manager-db" -}}
{{- print (index .Values "replicas-eric-enm-int-license-manager-db") -}}
{{- end -}}
{{- end -}}

{{/*
Create PG service
*/}}
{{- define "eric-enm-int-license-manager-db.pgService" -}}
{{- if and .Values.global .Values.global.enmProperties .Values.global.enmProperties.postgres_service -}}
{{- print .Values.global.enmProperties.postgres_service -}}
{{- else  -}}
{{- print "eric-lm-combined-server-db-pg" -}}
{{- end -}}
{{- end -}}

Generate Product info
*/}}
{{- define "eric-enm-int-license-manager-db.product-info" }}
ericsson.com/product-name: "helm-eric-enm-int-license-manager-db"
ericsson.com/product-number: "CXD 101 1213"
ericsson.com/product-revision: "{{.Values.productRevision}}"
{{- end}}

{{/*
Set IANA Timezone
DR-HC-146 requires setting a default TZ of UTC if the optional
global .Values.global.timezone and local .Values.timezone values are not set.
Unlike many other DRs, the global timezone value must override a local value.
*/}}
{{- define "eric-enm-int-license-manager-db.timezone" -}}
{{- $g := fromJson (include "eric-enm-int-license-manager-db.global" .) }}
{{- if and .Values.global .Values.global.enmProperties .Values.global.enmProperties.timezone -}}
{{- print .Values.global.enmProperties.timezone -}}
{{- else if $g.timezone -}}
{{- print $g.timezone -}}
{{- else -}}
{{- print .Values.timezone -}}
{{- end -}}
{{- end -}}
