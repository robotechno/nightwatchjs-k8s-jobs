#!/bin/bash
set -aeuo pipefail

PARTICIPANTID=$1

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  namespace: ${K8S_NAMESPACE}
  name: "${JOB_NAME}-${PARTICIPANTID}"
  labels:
    job: "${JOB_NAME}"
spec:
  ttlSecondsAfterFinished: 10
  template:
    metadata:
      labels:
        job: "${JOB_NAME}"
    spec:
      hostNetwork: true
#      dnsPolicy: ClusterFirstWithHostNet
      imagePullSecrets:
        - name: ${IMAGE_PULL_SECRET}
      restartPolicy: OnFailure
      containers:      
      - name: ${JOB_NAME}      
        image: ${ECR_DOMAIN}/${ECR_REPO}:${VERSION}
        imagePullPolicy: Always     
        env:
          - name: PARTICIPANTID
            value: "${PARTICIPANTID}"
          - name: DISPLAY
            value: "${DISPLAY}"
          - name: RESOLUTION
            value: "${RESOLUTION}"
          - name: TEST_NAME
            value: "${TEST_NAME}"
          - name: AWS_REGION
            value: "${AWS_REGION}"
          - name: AWS_ACCESS_KEY_ID
            valueFrom:
              secretKeyRef:
                name: ${S3_SECRET_NAME}
                key: aws-access-key-id
          - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              secretKeyRef:
                name: ${S3_SECRET_NAME}
                key: aws-secret-access-key
          - name: ENVIRONMENT
            value: "${ENVIRONMENT}"
          - name: STORAGE_ENDPOINT
            value: "${STORAGE_ENDPOINT}"
          - name: STORAGE_BUCKET
            value: "${STORAGE_BUCKET}"
          - name: RUN_TIME
            value: "${RUN_TIME}"
          - name: SLACK_CHANNEL
            value: "${SLACK_CHANNEL}" 
          - name: SLACK_IMCOMING_WEBHOOK_URL
            value: "${SLACK_IMCOMING_WEBHOOK_URL}"
          - name: SLACK_EMOJI
            value: "${SLACK_EMOJI}"
          - name: REPORTS_DOMAIN
            value: "${REPORTS_DOMAIN}"
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 1250m
            memory: 1Gi
EOF
