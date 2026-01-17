# Mattermost ARM64 Docker Image

Raspberry Pi 및 ARM64 아키텍처를 위한 Mattermost Docker 이미지 자동 빌드 및 배포 시스템입니다.

## 특징

- **ARM64 최적화**: Raspberry Pi 4/5 및 ARM64 시스템을 위한 네이티브 빌드
- **자동 업데이트**: 매일 새로운 Mattermost 릴리스를 자동으로 감지하고 빌드
- **다중 버전 태그**: `latest`, 메이저, 마이너, 패치 버전 태그 제공
- **GitHub Container Registry**: GHCR을 통한 빠르고 안정적인 이미지 배포
- **Docker Compose 지원**: PostgreSQL과 함께 즉시 배포 가능
- **헬스체크 내장**: 컨테이너 상태 자동 모니터링

## Quick Start

### Docker Compose로 실행 (권장)

PostgreSQL과 함께 완전한 Mattermost 스택을 배포합니다.

```bash
# 1. 필요한 파일 다운로드
wget https://raw.githubusercontent.com/zemyblue/mattermost-arm64-image/main/docker-compose.yml
wget https://raw.githubusercontent.com/zemyblue/mattermost-arm64-image/main/.env.example

# 2. 환경 설정 파일 생성 (선택 사항)
cp .env.example .env
# .env 파일을 열어서 필요한 설정 변경 (비밀번호, URL 등)

# 3. 실행
docker compose up -d

# 4. 로그 확인
docker compose logs -f

# 5. 웹 브라우저에서 접속
# http://localhost:8065
```

**참고**: `.env` 파일을 만들지 않아도 기본 설정으로 실행됩니다. 설정을 변경하고 싶을 때만 `.env` 파일을 생성하세요.

### Docker만 사용 (PostgreSQL 별도 필요)

```bash
# 이미지 다운로드
docker pull ghcr.io/zemyblue/mattermost-arm64:latest

# 실행 (PostgreSQL이 이미 실행 중이어야 함)
docker run -d \
  --name mattermost \
  -p 8065:8065 \
  -e MM_SQLSETTINGS_DATASOURCE="postgres://mmuser:password@postgres:5432/mattermost?sslmode=disable" \
  -v mattermost_data:/opt/mattermost/data \
  ghcr.io/zemyblue/mattermost-arm64:latest
```

**참고**: Mattermost는 PostgreSQL이 필수입니다. Docker Compose 사용을 권장합니다.

## Raspberry Pi에서 사용하기

Raspberry Pi에서 Mattermost를 설치하고 실행하는 방법은 별도 가이드를 참조하세요:

**📖 [Raspberry Pi 완전 가이드](HOWTO_RASPBERRY_PI.md)**

### 빠른 시작 (요약)

```bash
# 1. Docker 설치
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# 2. Mattermost 배포
mkdir -p ~/mattermost && cd ~/mattermost
wget https://raw.githubusercontent.com/zemyblue/mattermost-arm64-image/main/docker-compose.yml
docker compose up -d

# 3. 브라우저에서 접속
# http://raspberrypi.local:8065
```

자세한 내용은 [HOWTO_RASPBERRY_PI.md](HOWTO_RASPBERRY_PI.md)를 확인하세요.

## 환경 설정 (.env)

`.env` 파일을 사용하여 `docker-compose.yml`을 수정하지 않고 설정을 변경할 수 있습니다.

### 설정 파일 생성

```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env

# 에디터로 열어서 수정
nano .env
```

### 주요 설정 항목

| 카테고리 | 환경 변수 | 기본값 | 설명 |
|---------|----------|--------|------|
| **네트워크** | `MATTERMOST_HTTP_PORT` | `8065` | HTTP 포트 |
| | `MATTERMOST_SITE_URL` | `http://localhost:8065` | 사이트 URL |
| **데이터베이스** | `POSTGRES_USER` | `mmuser` | PostgreSQL 사용자 |
| | `POSTGRES_PASSWORD` | `mmuser_password` | PostgreSQL 비밀번호 ⚠️ |
| | `POSTGRES_DB` | `mattermost` | 데이터베이스 이름 |
| **볼륨** | `POSTGRES_DATA_PATH` | `postgres_data` | DB 데이터 경로 |
| | `MATTERMOST_DATA_PATH` | `mattermost_data` | 파일 저장 경로 |
| **이메일** | `EMAIL_VERIFICATION_REQUIRED` | `false` | 이메일 검증 필수 |
| | `SMTP_SERVER` | - | SMTP 서버 (프로덕션) |
| **기타** | `TIMEZONE` | `Asia/Seoul` | 타임존 |
| | `MAX_FILE_SIZE` | `104857600` | 최대 파일 크기 (100MB) |

### 일반적인 설정 예시

#### 1. 포트 변경

```env
MATTERMOST_HTTP_PORT=8080
MATTERMOST_SITE_URL=http://localhost:8080
```

#### 2. 비밀번호 변경 (권장)

```env
POSTGRES_PASSWORD=your_secure_password_here
```

#### 3. Bind Mount로 데이터 저장

```bash
# 먼저 디렉토리 생성
mkdir -p volumes/{postgres,mattermost/{data,logs,config,plugins}}

# .env 파일 수정
POSTGRES_DATA_PATH=./volumes/postgres
MATTERMOST_DATA_PATH=./volumes/mattermost/data
MATTERMOST_LOGS_PATH=./volumes/mattermost/logs
MATTERMOST_CONFIG_PATH=./volumes/mattermost/config
MATTERMOST_PLUGINS_PATH=./volumes/mattermost/plugins
```

#### 4. SMTP 이메일 설정 (Gmail 예시)

```env
EMAIL_VERIFICATION_REQUIRED=true
EMAIL_NOTIFICATIONS_ENABLED=true
SMTP_AUTH_ENABLED=true
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_NAME=Mattermost
SMTP_FROM_EMAIL=your-email@gmail.com
```

**Gmail 앱 비밀번호 생성**: https://myaccount.google.com/apppasswords

### 설정 적용

```bash
# 설정 변경 후 재시작
docker compose down
docker compose up -d
```

### 현재 설정 확인

```bash
# 환경 변수 확인
docker compose config

# 특정 서비스의 환경 변수
docker compose exec mattermost env | grep MM_
```

## 버전 태그 전략

이 프로젝트는 유연한 버전 관리를 위한 다중 태그 시스템을 사용합니다.

### 사용 가능한 태그

Mattermost 버전 `11.3.0`이 릴리스되면 다음 태그가 생성됩니다:

- `ghcr.io/zemyblue/mattermost-arm64:11.3.0` - 정확한 패치 버전
- `ghcr.io/zemyblue/mattermost-arm64:11.3` - 11.3.x의 최신 버전
- `ghcr.io/zemyblue/mattermost-arm64:11` - 11.x.x의 최신 버전
- `ghcr.io/zemyblue/mattermost-arm64:latest` - 전체 최신 버전

### 태그 선택 가이드

| 사용 사례 | 권장 태그 | 이유 |
|---------|---------|-----|
| 프로덕션 환경 | `11.3.0` | 정확한 버전 고정, 예상치 못한 업데이트 방지 |
| 테스트 환경 | `11.3` | 마이너 버전 내 패치 자동 적용 |
| 개발 환경 | `latest` | 항상 최신 기능 사용 |
| 메이저 버전 고정 | `11` | 메이저 버전 내에서 최신 상태 유지 |

### 예제

```bash
# 프로덕션: 정확한 버전 사용
docker pull ghcr.io/zemyblue/mattermost-arm64:11.3.0

# 스테이징: 마이너 버전의 최신 패치
docker pull ghcr.io/zemyblue/mattermost-arm64:11.3

# 개발: 최신 버전
docker pull ghcr.io/zemyblue/mattermost-arm64:latest
```

## 고급 설정

### Mattermost 환경 변수

`.env` 파일을 통해 주요 설정을 변경할 수 있습니다. 자세한 내용은 위의 **환경 설정 (.env)** 섹션을 참조하세요.

고급 Mattermost 설정이 필요한 경우, `MM_` 접두사를 가진 환경 변수를 추가할 수 있습니다:

```yaml
# docker-compose.yml의 mattermost 서비스에 추가
environment:
  MM_TEAMSETTINGS_MAXUSERSPERTEAM: 100
  MM_SERVICESETTINGS_ENABLEDEVELOPER: "true"
```

전체 환경 변수 목록은 [Mattermost 공식 문서](https://docs.mattermost.com/configure/configuration-settings.html)를 참조하세요.

## 볼륨

| 경로 | 용도 |
|-----|-----|
| `/opt/mattermost/data` | 업로드된 파일 및 데이터 |
| `/opt/mattermost/logs` | 애플리케이션 로그 |
| `/opt/mattermost/config` | 설정 파일 |
| `/opt/mattermost/plugins` | 플러그인 |

### 백업

중요한 데이터를 백업하려면:

```bash
# 볼륨 백업
docker run --rm \
  -v mattermost_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mattermost_data_backup.tar.gz -C /data .

# PostgreSQL 백업
docker compose exec postgres pg_dump -U mmuser mattermost > mattermost_db_backup.sql
```

### 복원

```bash
# 볼륨 복원
docker run --rm \
  -v mattermost_data:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/mattermost_data_backup.tar.gz"

# PostgreSQL 복원
docker compose exec -T postgres psql -U mmuser mattermost < mattermost_db_backup.sql
```

## 트러블슈팅

### Mattermost가 시작되지 않음

1. 로그 확인:
   ```bash
   docker logs mattermost
   # 또는
   docker compose logs mattermost
   ```

2. PostgreSQL 연결 확인:
   ```bash
   docker compose exec postgres pg_isready -U mmuser
   ```

3. 포트 충돌 확인:
   ```bash
   sudo netstat -tlnp | grep 8065
   ```

### 데이터베이스 연결 오류

PostgreSQL이 완전히 시작되기 전에 Mattermost가 시작하는 경우:

```bash
# 컨테이너 재시작
docker compose restart mattermost

# 또는 depends_on 조건 확인
docker compose ps
```

### 권한 문제

볼륨 권한 문제가 발생하는 경우:

```bash
# 컨테이너 내부에서 확인
docker compose exec mattermost ls -la /opt/mattermost/

# 권한 수정 (필요시)
docker compose exec --user root mattermost chown -R mattermost:mattermost /opt/mattermost/
```

### 메모리 부족 (Raspberry Pi)

Raspberry Pi에서 메모리 부족 문제가 발생하는 경우:

1. 스왑 증가:
   ```bash
   sudo dphys-swapfile swapoff
   sudo nano /etc/dphys-swapfile
   # CONF_SWAPSIZE=2048로 변경
   sudo dphys-swapfile setup
   sudo dphys-swapfile swapon
   ```

2. PostgreSQL 메모리 설정 조정:
   ```yaml
   # docker-compose.yml에 추가
   postgres:
     command: postgres -c shared_buffers=128MB -c max_connections=100
   ```

### 이미지 pull 실패

```bash
# GHCR 인증 (private repository인 경우)
echo $GITHUB_TOKEN | docker login ghcr.io -u zemyblue --password-stdin

# 네트워크 확인
docker pull alpine:latest
```

## 로컬 빌드

GHCR 이미지 대신 직접 빌드하려는 경우:

### 기본 빌드

```bash
# 기본 버전(11.3.0)으로 빌드
docker build -t mattermost-arm64:local .

# 특정 버전 지정
docker build \
  --build-arg MATTERMOST_VERSION=11.2.0 \
  -t mattermost-arm64:11.2.0 \
  .
```

### 멀티 플랫폼 빌드 (선택)

```bash
# Buildx 설정
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap

# ARM64 + AMD64 빌드
docker buildx build \
  --platform linux/arm64,linux/amd64 \
  --build-arg MATTERMOST_VERSION=11.3.0 \
  -t mattermost:11.3.0 \
  --push \
  .
```

### Docker Compose로 로컬 빌드

`docker-compose.yml`에서 `image:` 라인을 주석 처리하고 `build:` 섹션의 주석을 해제합니다:

```yaml
mattermost:
  # image: ghcr.io/zemyblue/mattermost-arm64:latest
  build:
    context: .
    dockerfile: Dockerfile
    args:
      MATTERMOST_VERSION: 11.3.0
```

그 다음:

```bash
docker compose build
docker compose up -d
```

## 자동 빌드 시스템

이 프로젝트는 GitHub Actions를 사용하여 자동으로 새로운 Mattermost 릴리스를 감지하고 빌드합니다.

### 작동 방식

1. **스케줄**: 매일 00:00 UTC에 자동 실행
2. **버전 감지**: GitHub API를 통해 최신 Mattermost 릴리스 확인
3. **중복 확인**: GHCR에 해당 버전이 이미 존재하는지 확인
4. **빌드**: 새 버전 발견 시 ARM64 이미지 빌드
5. **배포**: 다중 태그로 GHCR에 푸시

### 수동 빌드 트리거

GitHub Actions 탭에서 "Build and Push Docker Image" 워크플로우를 수동으로 실행할 수 있습니다:

- `version`: 빌드할 Mattermost 버전 (예: `11.3.0`)
- `force_build`: 기존 이미지가 있어도 강제로 재빌드

## 기여

이슈 및 풀 리퀘스트를 환영합니다.

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

Mattermost는 별도의 라이선스를 가지고 있습니다. 자세한 내용은 [Mattermost 라이선스](https://github.com/mattermost/mattermost/blob/master/LICENSE.txt)를 참조하세요.

## 관련 링크

- [Mattermost 공식 웹사이트](https://mattermost.com/)
- [Mattermost GitHub](https://github.com/mattermost/mattermost)
- [Mattermost 문서](https://docs.mattermost.com/)
- [GitHub Container Registry](https://github.com/features/packages)

## 지원

문제가 발생하거나 질문이 있으시면 [이슈](https://github.com/zemyblue/mattermost-arm64-image/issues)를 생성해주세요.
