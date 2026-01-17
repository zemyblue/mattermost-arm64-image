# Raspberry Pi에서 Mattermost 설치 및 실행 가이드

Raspberry Pi에서 Mattermost를 Docker로 간편하게 설치하고 실행하는 완전 가이드입니다.

## 사전 요구사항

### 하드웨어
- **Raspberry Pi 4 또는 5** (권장: 4GB RAM 이상)
- **64GB 이상 SD 카드** (데이터 저장 공간 고려)
- **안정적인 전원 공급** (5V 3A 이상)
- **네트워크 연결** (유선 또는 무선)

### 소프트웨어
- **Raspberry Pi OS (64-bit)** - 최신 버전 권장
- 인터넷 연결

## 1단계: Raspberry Pi OS 설치

### Raspberry Pi Imager 사용

1. [Raspberry Pi Imager](https://www.raspberrypi.com/software/) 다운로드
2. SD 카드 삽입
3. OS 선택: **Raspberry Pi OS (64-bit)**
4. 설정 (톱니바퀴 아이콘):
   - 호스트명: `raspberrypi` (또는 원하는 이름)
   - SSH 활성화
   - 사용자명/비밀번호 설정
   - Wi-Fi 설정 (필요시)
5. 쓰기 시작

### 첫 부팅

```bash
# SSH로 접속 (macOS/Linux)
ssh pi@raspberrypi.local

# 또는 IP 주소로
ssh pi@192.168.1.100

# 시스템 업데이트
sudo apt update && sudo apt upgrade -y
```

## 2단계: Docker 설치

### Docker 자동 설치 스크립트

```bash
# Docker 설치 스크립트 다운로드 및 실행
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 설치 확인
docker --version
# 출력 예시: Docker version 24.0.7, build afdd53b
```

### 사용자 권한 설정

```bash
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 변경사항 적용 (재로그인 또는 다음 명령어 실행)
newgrp docker

# 권한 확인 (sudo 없이 실행 가능해야 함)
docker ps
```

### Docker Compose 설치

```bash
# Docker Compose Plugin 설치
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# 설치 확인
docker compose version
# 출력 예시: Docker Compose version v2.23.3
```

## 3단계: Mattermost 배포

### 방법 1: docker-compose.yml 다운로드 (권장)

```bash
# 1. 작업 디렉토리 생성
mkdir -p ~/mattermost
cd ~/mattermost

# 2. docker-compose.yml 다운로드
wget https://raw.githubusercontent.com/zemyblue/mattermost-arm64-image/main/docker-compose.yml

# 3. (선택) 설정 수정
nano docker-compose.yml
# - POSTGRES_PASSWORD 변경
# - MM_SERVICESETTINGS_SITEURL 변경 (자신의 라즈베리파이 주소)

# 4. Mattermost 시작
docker compose up -d

# 5. 로그 확인
docker compose logs -f mattermost
```

### 방법 2: Git Clone

```bash
# 1. Git 설치 (설치되지 않은 경우)
sudo apt install -y git

# 2. 저장소 클론
git clone https://github.com/zemyblue/mattermost-arm64-image.git
cd mattermost-arm64-image

# 3. 실행
docker compose up -d
```

### 컨테이너 상태 확인

```bash
# 실행 중인 컨테이너 확인
docker compose ps

# 출력 예시:
# NAME                COMMAND                  SERVICE      STATUS       PORTS
# mattermost          "/opt/mattermost/bin…"   mattermost   Up 2 minutes 0.0.0.0:8065->8065/tcp
# postgres            "docker-entrypoint.s…"   postgres     Up 2 minutes 5432/tcp

# 로그 확인
docker compose logs mattermost
docker compose logs postgres
```

## 4단계: Mattermost 초기 설정

### 웹 브라우저 접속

1. **로컬 네트워크에서**:
   ```
   http://raspberrypi.local:8065
   ```

2. **IP 주소로**:
   ```bash
   # Raspberry Pi IP 확인
   hostname -I
   # 출력: 192.168.1.100

   # 브라우저에서 접속
   http://192.168.1.100:8065
   ```

### 관리자 계정 생성

1. "Create an account" 클릭
2. 관리자 정보 입력:
   - 이메일 주소
   - 사용자명
   - 비밀번호
3. "Create Account" 클릭

### 팀 생성

1. 팀 이름 입력 (예: "My Team")
2. "Next" 클릭
3. 팀 설정 완료

## 5단계: 환경 설정 (선택)

### 환경 변수 커스터마이징

`docker-compose.yml`에서 설정 가능한 주요 환경 변수:

```yaml
environment:
  # 타임존 설정
  TZ: Asia/Seoul  # 또는 America/New_York, Europe/London 등

  # 사이트 URL (외부 접속 시 설정)
  MM_SERVICESETTINGS_SITEURL: http://192.168.1.100:8065

  # 파일 업로드 크기 제한 (기본: 50MB)
  MM_FILESETTINGS_MAXFILESIZE: 104857600  # 100MB

  # 이메일 알림 설정 (SMTP)
  MM_EMAILSETTINGS_ENABLESMTPAUTH: "true"
  MM_EMAILSETTINGS_SMTPUSERNAME: "your-email@gmail.com"
  MM_EMAILSETTINGS_SMTPPASSWORD: "your-app-password"
  MM_EMAILSETTINGS_SMTPSERVER: "smtp.gmail.com"
  MM_EMAILSETTINGS_SMTPPORT: "587"
```

설정 변경 후:
```bash
docker compose down
docker compose up -d
```

### 외부에서 접속하기 (포트 포워딩)

공유기에서 포트 포워딩 설정:
- **외부 포트**: 8065 (또는 원하는 포트)
- **내부 IP**: Raspberry Pi IP (예: 192.168.1.100)
- **내부 포트**: 8065

그 다음:
```yaml
# docker-compose.yml에서 SITEURL 변경
MM_SERVICESETTINGS_SITEURL: http://your-public-ip:8065
```

**보안 권장사항**: 외부 노출 시 HTTPS 설정 필요 (Nginx + Let's Encrypt 사용)

## 관리 명령어

### 기본 명령어

```bash
# Mattermost 시작
docker compose up -d

# Mattermost 중지
docker compose down

# 재시작
docker compose restart

# 로그 실시간 확인
docker compose logs -f

# 특정 서비스 로그만 보기
docker compose logs -f mattermost
docker compose logs -f postgres

# 컨테이너 상태 확인
docker compose ps

# 리소스 사용량 확인
docker stats
```

### 업데이트

```bash
# 최신 이미지 다운로드
docker compose pull

# 재시작 (새 버전 적용)
docker compose down
docker compose up -d

# 이전 이미지 정리
docker image prune -a
```

### 데이터 백업

```bash
# PostgreSQL 데이터베이스 백업
docker compose exec postgres pg_dump -U mmuser mattermost > mattermost_backup_$(date +%Y%m%d).sql

# 업로드 파일 백업
docker run --rm \
  -v mattermost_mattermost_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mattermost_files_$(date +%Y%m%d).tar.gz -C /data .

# 백업 파일 확인
ls -lh mattermost_*.{sql,tar.gz}
```

### 데이터 복원

```bash
# PostgreSQL 복원
docker compose exec -T postgres psql -U mmuser mattermost < mattermost_backup_20260117.sql

# 파일 복원
docker run --rm \
  -v mattermost_mattermost_data:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/mattermost_files_20260117.tar.gz"

# 재시작
docker compose restart
```

## 트러블슈팅

### Mattermost가 시작되지 않음

**로그 확인**:
```bash
docker compose logs mattermost
```

**일반적인 원인**:
1. PostgreSQL이 준비되지 않음 → 1-2분 대기 후 `docker compose restart mattermost`
2. 포트 충돌 → `sudo netstat -tlnp | grep 8065`로 확인
3. 메모리 부족 → `free -h`로 확인

### 파일 업로드/플러그인 설치 실패 (권한)

파일 업로드나 플러그인 설치 시 `/opt/mattermost/data`, `/opt/mattermost/plugins`에 쓰기 실패가 발생하면
볼륨 권한 문제일 가능성이 높습니다. 컨테이너는 UID/GID 2000으로 실행됩니다.

**Bind mount 사용 시 (권장)**:
```bash
sudo chown -R 2000:2000 volumes/mattermost volumes/postgres
sudo chmod -R 775 volumes/mattermost volumes/postgres
```

**Named volume 사용 시**:
```bash
docker compose exec --user root mattermost chown -R mattermost:mattermost /opt/mattermost/
```

### 메모리 부족 문제

Raspberry Pi 4GB 이하 모델에서 메모리 부족 발생 시:

```bash
# 1. 스왑 파일 크기 증가
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# CONF_SWAPSIZE=2048 로 변경

sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# 2. PostgreSQL 메모리 설정 조정
# docker-compose.yml에 추가:
postgres:
  command: postgres -c shared_buffers=128MB -c max_connections=50
```

### 접속이 안 됨

**방화벽 확인**:
```bash
# 포트 8065가 열려있는지 확인
sudo ufw status

# UFW 사용 시 포트 열기
sudo ufw allow 8065/tcp
```

**네트워크 확인**:
```bash
# Raspberry Pi IP 확인
hostname -I

# 포트가 리스닝 중인지 확인
sudo netstat -tlnp | grep 8065
```

**같은 네트워크에서 테스트**:
```bash
# Raspberry Pi에서 직접 테스트
curl http://localhost:8065/api/v4/system/ping
# 출력: {"status":"OK"}
```

### 데이터베이스 연결 오류

```bash
# PostgreSQL 상태 확인
docker compose exec postgres pg_isready -U mmuser

# 비밀번호 확인 (docker-compose.yml에서)
# POSTGRES_PASSWORD와 MM_SQLSETTINGS_DATASOURCE의 비밀번호가 일치해야 함
```

### 느린 성능

```bash
# 1. SD 카드 성능 확인
sudo dd if=/dev/zero of=./test.img bs=1M count=1024 oflag=direct
sudo rm test.img

# 2. 리소스 사용량 확인
docker stats

# 3. 로그 레벨 조정 (docker-compose.yml)
MM_LOGSETTINGS_CONSOLELEVEL: "ERROR"  # 기본값: INFO
```

## 성능 최적화

### Raspberry Pi 설정

```bash
# 1. GPU 메모리 최소화 (헤드리스 서버)
sudo nano /boot/config.txt
# gpu_mem=16 추가

# 2. Over-clocking (Raspberry Pi 4, 주의 필요)
# arm_freq=2000
# over_voltage=6

# 3. 재부팅
sudo reboot
```

### Docker 최적화

```bash
# 로그 크기 제한
# /etc/docker/daemon.json 생성
sudo nano /etc/docker/daemon.json
```

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

```bash
sudo systemctl restart docker
docker compose up -d
```

## 자동 시작 설정

### 부팅 시 자동 시작

```bash
# 1. systemd 서비스 파일 생성
sudo nano /etc/systemd/system/mattermost.service
```

```ini
[Unit]
Description=Mattermost Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/pi/mattermost
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

```bash
# 2. 서비스 활성화
sudo systemctl enable mattermost.service
sudo systemctl start mattermost.service

# 3. 상태 확인
sudo systemctl status mattermost.service
```

## 고급: HTTPS 설정 (Nginx + Let's Encrypt)

외부 접속 시 HTTPS 설정이 필요한 경우:

```bash
# 1. Nginx 설치
sudo apt install -y nginx certbot python3-certbot-nginx

# 2. Nginx 설정
sudo nano /etc/nginx/sites-available/mattermost
```

```nginx
server {
    listen 80;
    server_name mattermost.yourdomain.com;

    location / {
        proxy_pass http://localhost:8065;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# 3. 설정 활성화
sudo ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 4. SSL 인증서 발급
sudo certbot --nginx -d mattermost.yourdomain.com
```

## 리소스 요구사항

### 최소 요구사항
- **RAM**: 2GB (경량 사용)
- **저장공간**: 16GB
- **사용자**: 1-10명

### 권장 사양
- **RAM**: 4GB 이상
- **저장공간**: 64GB 이상 (SSD 권장)
- **사용자**: 10-50명
- **모델**: Raspberry Pi 4/5

### 대규모 사용
- **RAM**: 8GB
- **저장공간**: 256GB SSD
- **사용자**: 50-100명
- **모델**: Raspberry Pi 5
- **추가**: 외부 PostgreSQL 서버 권장

## 참고 링크

- [Mattermost 공식 문서](https://docs.mattermost.com/)
- [Docker 공식 문서](https://docs.docker.com/)
- [Raspberry Pi 문서](https://www.raspberrypi.com/documentation/)
- [프로젝트 GitHub](https://github.com/zemyblue/mattermost-arm64-image)

## 문제 해결 및 지원

문제가 발생하면:
1. 로그 확인: `docker compose logs -f`
2. GitHub Issues: https://github.com/zemyblue/mattermost-arm64-image/issues
3. Mattermost 커뮤니티: https://community.mattermost.com/

---

**즐거운 Mattermost 사용 되세요!** 🎉
