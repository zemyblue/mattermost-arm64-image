FROM alpine:3.19

# Mattermost 버전 (빌드 시 지정 가능)
ARG MATTERMOST_VERSION=11.3.0

# 필수 패키지 설치 및 Mattermost 다운로드 (레이어 최적화)
RUN apk add --no-cache \
    ca-certificates \
    curl \
    netcat-openbsd \
    tzdata && \
    wget https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-arm64.tar.gz && \
    tar -xzf mattermost-${MATTERMOST_VERSION}-linux-arm64.tar.gz && \
    rm mattermost-${MATTERMOST_VERSION}-linux-arm64.tar.gz && \
    mv mattermost /opt/ && \
    addgroup -g 2000 mattermost && \
    adduser -D -u 2000 -G mattermost mattermost && \
    chown -R mattermost:mattermost /opt/mattermost && \
    mkdir -p /opt/mattermost/data /opt/mattermost/logs /opt/mattermost/config /opt/mattermost/plugins

WORKDIR /opt/mattermost

# 데이터 영속성을 위한 볼륨 선언
VOLUME ["/opt/mattermost/data", "/opt/mattermost/logs", "/opt/mattermost/config", "/opt/mattermost/plugins"]

USER mattermost

EXPOSE 8065 8067 8074 8075

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

CMD ["/opt/mattermost/bin/mattermost"]
