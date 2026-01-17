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

### Docker로 실행

```bash
docker pull ghcr.io/YOUR_GITHUB_USERNAME/mattermost-arm64:latest

docker run -d \
  --name mattermost \
  -p 8065:8065 \
  -v mattermost_data:/opt/mattermost/data \
  -v mattermost_config:/opt/mattermost/config \
  -v mattermost_logs:/opt/mattermost/logs \
  -v mattermost_plugins:/opt/mattermost/plugins \
  ghcr.io/YOUR_GITHUB_USERNAME/mattermost-arm64:latest
```

웹 브라우저에서 `http://localhost:8065`에 접속합니다.

### Docker Compose로 실행 (권장)

PostgreSQL과 함께 완전한 Mattermost 스택을 배포합니다.

1. `docker-compose.yml` 파일 수정:
   ```yaml
   # YOUR_GITHUB_USERNAME을 본인의 GitHub username으로 변경
   image: ghcr.io/YOUR_GITHUB_USERNAME/mattermost-arm64:latest
   ```

2. 실행:
   ```bash
   docker-compose up -d
   ```

3. 로그 확인:
   ```bash
   docker-compose logs -f mattermost
   ```

4. 중지:
   ```bash
   docker-compose down
   ```

## Raspberry Pi 설정 가이드

### 사전 요구사항

- Raspberry Pi 4 또는 5 (권장: 4GB RAM 이상)
- Raspberry Pi OS (64-bit)
- Docker 및 Docker Compose 설치

### Docker 설치

```bash
# Docker 설치 스크립트 실행
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 재로그인 또는 다음 명령어 실행
newgrp docker

# Docker Compose 설치 (V2)
sudo apt-get update
sudo apt-get install docker-compose-plugin

# 설치 확인
docker --version
docker compose version
```

### Mattermost 배포

1. 프로젝트 디렉토리 생성:
   ```bash
   mkdir -p ~/mattermost
   cd ~/mattermost
   ```

2. `docker-compose.yml` 다운로드:
   ```bash
   wget https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/mattermost-arm64-image/main/docker-compose.yml
   ```

3. 환경 변수 설정 (선택):
   ```bash
   # .env 파일 생성
   cat > .env <<EOF
   TZ=Asia/Seoul
   POSTGRES_PASSWORD=your_secure_password
   MM_SERVICESETTINGS_SITEURL=http://raspberrypi.local:8065
   EOF
   ```

4. 실행:
   ```bash
   docker compose up -d
   ```

5. 초기 설정:
   - 브라우저에서 `http://raspberrypi.local:8065` 접속
   - 관리자 계정 생성
   - 팀 생성 및 설정

## 버전 태그 전략

이 프로젝트는 유연한 버전 관리를 위한 다중 태그 시스템을 사용합니다.

### 사용 가능한 태그

Mattermost 버전 `11.3.0`이 릴리스되면 다음 태그가 생성됩니다:

- `ghcr.io/USER/mattermost-arm64:11.3.0` - 정확한 패치 버전
- `ghcr.io/USER/mattermost-arm64:11.3` - 11.3.x의 최신 버전
- `ghcr.io/USER/mattermost-arm64:11` - 11.x.x의 최신 버전
- `ghcr.io/USER/mattermost-arm64:latest` - 전체 최신 버전

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
docker pull ghcr.io/USER/mattermost-arm64:11.3.0

# 스테이징: 마이너 버전의 최신 패치
docker pull ghcr.io/USER/mattermost-arm64:11.3

# 개발: 최신 버전
docker pull ghcr.io/USER/mattermost-arm64:latest
```

## 환경 변수

### 데이터베이스 설정

| 변수 | 기본값 | 설명 |
|-----|-------|-----|
| `MM_SQLSETTINGS_DRIVERNAME` | `postgres` | 데이터베이스 드라이버 |
| `MM_SQLSETTINGS_DATASOURCE` | - | PostgreSQL 연결 문자열 |

### 서버 설정

| 변수 | 기본값 | 설명 |
|-----|-------|-----|
| `MM_SERVICESETTINGS_SITEURL` | `http://localhost:8065` | 서버 URL |
| `MM_SERVICESETTINGS_ENABLELOCALMODE` | `true` | 로컬 모드 활성화 |
| `TZ` | `UTC` | 타임존 |

### 파일 및 플러그인

| 변수 | 기본값 | 설명 |
|-----|-------|-----|
| `MM_FILESETTINGS_DIRECTORY` | `/opt/mattermost/data` | 파일 저장 경로 |
| `MM_PLUGINSETTINGS_DIRECTORY` | `/opt/mattermost/plugins` | 플러그인 경로 |

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
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

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
  # image: ghcr.io/USER/mattermost-arm64:latest
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

문제가 발생하거나 질문이 있으시면 [이슈](https://github.com/YOUR_GITHUB_USERNAME/mattermost-arm64-image/issues)를 생성해주세요.
