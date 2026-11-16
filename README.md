# 개발 워크스테이션 구축 (Dev Workstation)

> 입학연수 1과제 — 터미널 · Docker · Git/GitHub 기반 재현 가능한 개발 환경 구축
>
> 이 README 하나만 읽어도 전체 수행 내용과 검증 결과를 파악할 수 있도록 작성되었습니다.

---

## 📌 사용 방법 (제출 전 반드시 확인)

이 저장소는 **바로 실행 가능한 템플릿**입니다. 아래 순서로 진행하세요.

1. 본인 컴퓨터(OrbStack 실행 상태)에서 각 섹션의 명령을 **직접 실행**합니다.
2. 명령의 **실제 출력**을 각 코드블록의 `# 출력 ↓` 아래에 붙여넣습니다.
3. 브라우저 접속 화면 등 **스크린샷**은 `docs/images/` 에 저장하고 이미지 링크를 교체합니다.
4. `⬜ TODO` / `<!-- 붙여넣기 -->` 표시는 본인 결과로 모두 바꿉니다.
5. 토큰·비밀번호 등 민감정보가 캡처에 들어가지 않도록 **마스킹**합니다.

> ⚠️ 예시 출력은 참고용입니다. 그대로 제출하지 말고 본인 환경 결과로 교체하세요.

---

## 1) 프로젝트 개요

- **목표**: 터미널(CLI), Docker(컨테이너), Git/GitHub를 직접 다뤄 "내 컴퓨터에서만 돌아가는" 문제를 줄이고, 누구나 동일하게 실행·배포·디버깅할 수 있는 재현 가능한 개발 환경을 구성한다.
- **핵심 산출물**: 커스텀 Docker 이미지로 동작하는 웹 서버, 포트 매핑 접속, 바인드 마운트 반영, 볼륨 영속성, Git/GitHub 연동.
- **구성**: nginx 베이스 이미지에 직접 만든 정적 콘텐츠를 교체한 커스텀 웹 서버(옵션 A).

### 저장소 구조
```
dev-workstation/
├── README.md              # 기술 문서 (이 파일)
├── Dockerfile             # 커스텀 이미지 정의 (nginx + 정적 콘텐츠)
├── docker-compose.yml     # (보너스) 단일 서비스 Compose 실행
├── .dockerignore
├── .gitignore
├── site/                  # 웹 서버 소스 (정적 콘텐츠)
│   ├── index.html
│   └── style.css
└── docs/
    └── images/            # 스크린샷 증거 저장 위치
```

---

## 2) 실행 환경

> `# 출력 ↓` 아래를 본인 환경 결과로 교체하세요.

```bash
# OS / 커널
uname -a
# 출력 ↓
<!-- 붙여넣기 -->

# 쉘
echo $SHELL
# 출력 ↓
<!-- 붙여넣기 -->

docker --version
# 출력 ↓  예) Docker version 27.x, build ...
<!-- 붙여넣기 -->

git --version
# 출력 ↓  예) git version 2.x
<!-- 붙여넣기 -->
```

| 항목 | 값 |
|------|-----|
| OS | ⬜ (예: macOS 15 / Ubuntu 22.04) |
| Shell / 터미널 | ⬜ (예: zsh / bash) |
| 컨테이너 런타임 | ⬜ (예: OrbStack — Docker engine 내장) |
| Docker 버전 | ⬜ |
| Git 버전 | ⬜ |

> 서울캠퍼스: sudo 제약으로 Docker를 직접 설치하지 않고 **OrbStack**을 사용했습니다. OrbStack 실행 시 Docker 엔진이 함께 구동되며 터미널에서 `docker` 명령을 동일하게 사용합니다.

---

## 3) 수행 항목 체크리스트

- [ ] 터미널 기본 조작 및 폴더 구성
- [ ] 파일/디렉토리 권한 변경 실습 (변경 전/후 비교)
- [ ] Docker 설치/점검 (`docker --version`, `docker info`)
- [ ] 기본 운영 명령 (`images` / `ps` / `logs` / `stats`)
- [ ] `hello-world` 실행
- [ ] `ubuntu` 컨테이너 진입 및 명령 실행
- [ ] Dockerfile 기반 커스텀 이미지 빌드/실행
- [ ] 포트 매핑 접속 성공 (2회, 포트 2개)
- [ ] 바인드 마운트 변경 반영 확인
- [ ] Docker 볼륨 영속성 확인 (컨테이너 삭제 전/후)
- [ ] Git 사용자/기본 브랜치 설정 + `git config --list`
- [ ] GitHub 로그인 및 저장소 연동 (VSCode)

---

## 4) 터미널 조작 로그

> 아래 명령을 실행하고 **입력 + 출력**을 함께 남기세요.

```bash
# 현재 위치 확인
pwd

# 작업 디렉토리 생성 및 이동
mkdir -p ~/codyssey/practice
cd ~/codyssey/practice

# 목록 확인 (숨김 파일 포함)
ls -la

# 빈 파일 생성 / 복사 / 이름변경 / 삭제
touch sample.txt
cp sample.txt sample_copy.txt
mv sample_copy.txt renamed.txt
rm renamed.txt

# 파일 내용 확인
echo "hello codyssey" > sample.txt
cat sample.txt
```

```text
# 출력 ↓ (위 명령들의 실제 터미널 출력을 붙여넣으세요)
<!-- 붙여넣기 -->
```

---

## 5) 권한(Permission) 실습

> 파일 1개 + 디렉토리 1개에 대해 권한 변경 전/후를 비교합니다.

```bash
# 대상 준비
touch perm_file.txt
mkdir perm_dir

# 변경 전 권한 확인
ls -l perm_file.txt
ls -ld perm_dir

# 파일 권한 변경 (644 = rw-r--r--)
chmod 644 perm_file.txt

# 디렉토리 권한 변경 (755 = rwxr-xr-x)
chmod 755 perm_dir

# 변경 후 권한 확인
ls -l perm_file.txt
ls -ld perm_dir
```

| 대상 | 변경 전 | 변경 후 | 의미 |
|------|---------|---------|------|
| `perm_file.txt` | ⬜ | `-rw-r--r--` (644) | 소유자 읽기/쓰기, 그 외 읽기 |
| `perm_dir` | ⬜ | `drwxr-xr-x` (755) | 소유자 전체, 그 외 읽기/실행 |

```text
# 출력 ↓ (변경 전/후 ls 결과)
<!-- 붙여넣기 -->
```

---

## 6) Docker 설치 및 기본 점검

```bash
docker --version
docker info
```

```text
# 출력 ↓  (docker info 는 길므로 핵심 부분 — Server Running, Containers, Images 등 — 발췌 가능)
<!-- 붙여넣기 -->
```

---

## 7) Docker 기본 운영 명령

```bash
# 이미지 목록
docker images

# 실행 중 / 전체 컨테이너
docker ps
docker ps -a

# 로그 / 리소스
docker logs <컨테이너명>
docker stats --no-stream
```

```text
# 출력 ↓
<!-- 붙여넣기 -->
```

---

## 8) 컨테이너 실행 실습

### 8-1. hello-world
```bash
docker run hello-world
```
```text
# 출력 ↓  ("Hello from Docker!" 메시지 포함)
<!-- 붙여넣기 -->
```

### 8-2. ubuntu 진입 후 명령
```bash
docker run -it ubuntu bash
# 컨테이너 내부에서:
ls /
echo "inside container"
exit
```
```text
# 출력 ↓
<!-- 붙여넣기 -->
```

### 8-3. attach vs exec / 종료·유지 차이 (직접 관찰 후 정리)
- `docker run -it ... bash` 에서 `exit` 하면 → ⬜ (컨테이너 종료됨/유지됨?)
- `docker run -d ...` 로 백그라운드 실행 후 `docker exec -it <name> bash` 로 진입했다가 `exit` 하면 → ⬜
- 관찰 요약: ⬜ (한두 문장)

---

## 9) 커스텀 이미지 제작 (Dockerfile)

**선택한 베이스**: `nginx:alpine` (옵션 A — 웹 서버 베이스 + 정적 콘텐츠 교체)

**적용한 커스텀 포인트**
| 포인트 | 목적 |
|--------|------|
| `LABEL` 메타데이터 | 이미지 식별/문서화 |
| `ENV APP_ENV=dev` | 환경 변수로 실행 모드 분리 |
| `COPY site/ ...` | 내가 만든 정적 콘텐츠로 기본 페이지 교체 |
| `HEALTHCHECK` | 컨테이너 상태 점검 자동화 |

```bash
# 빌드
docker build -t my-web:1.0 .

# 확인
docker images | grep my-web
```
```text
# 출력 ↓ (빌드 성공 로그 + 이미지 목록)
<!-- 붙여넣기 -->
```

---

## 10) 포트 매핑 및 접속 증거

> 포트를 2개 사용해 2회 접속을 확인합니다. (같은 이미지, 다른 host 포트)

```bash
# 8080 포트로 실행
docker run -d -p 8080:80 --name my-web-8080 my-web:1.0

# 8081 포트로 실행
docker run -d -p 8081:80 --name my-web-8081 my-web:1.0

# 터미널 확인
curl http://localhost:8080
curl http://localhost:8081

docker ps
```
```text
# 출력 ↓ (curl 응답 + docker ps)
<!-- 붙여넣기 -->
```

**브라우저 접속 화면 (주소창 + 포트 포함):**

![포트 8080 접속](docs/images/port-8080.png)
![포트 8081 접속](docs/images/port-8081.png)

> ⬜ 위 두 이미지를 `docs/images/` 에 실제 캡처로 저장하세요. (주소창에 `localhost:8080`, `localhost:8081` 이 보여야 함)

---

## 11) 바인드 마운트 반영 + 볼륨 영속성

### 11-1. 바인드 마운트 (변경 즉시 반영)
```bash
# site/ 를 컨테이너 웹 루트로 바인드 마운트
docker run -d -p 8082:80 \
  -v "$(pwd)/site:/usr/share/nginx/html:ro" \
  --name my-web-mount my-web:1.0

# → 브라우저에서 localhost:8082 확인 (변경 전)
# → site/index.html 의 문구를 수정하고 저장
# → 브라우저 새로고침 → 재빌드 없이 변경 반영 확인 (변경 후)
```
- 변경 전 화면: `docs/images/mount-before.png`
- 변경 후 화면: `docs/images/mount-after.png`

![마운트 전](docs/images/mount-before.png)
![마운트 후](docs/images/mount-after.png)

### 11-2. Docker 볼륨 (영속성)
```bash
# 볼륨 생성 + 연결
docker volume create mydata
docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity

# 데이터 기록
docker exec vol-test bash -lc "echo hi > /data/hello.txt && cat /data/hello.txt"

# 컨테이너 삭제
docker rm -f vol-test

# 새 컨테이너에 같은 볼륨 연결 → 데이터 유지 확인
docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
docker exec vol-test2 bash -lc "cat /data/hello.txt"
```
```text
# 출력 ↓ (삭제 전 'hi' 기록 → 컨테이너 삭제 → 새 컨테이너에서 'hi' 그대로 출력)
<!-- 붙여넣기 -->
```
> ✅ 컨테이너를 삭제해도 볼륨에 저장된 데이터가 유지됨을 확인. (이미지/컨테이너와 데이터의 분리)

### 정리 (실습 종료 후)
```bash
docker rm -f my-web-8080 my-web-8081 my-web-mount vol-test2 2>/dev/null
docker volume rm mydata 2>/dev/null
```

---

## 12) Git 설정 및 GitHub 연동

```bash
# 사용자 정보 / 기본 브랜치 설정
git config --global user.name "본인이름"
git config --global user.email "본인메일"
git config --global init.defaultBranch main

# 설정 확인
git config --list
```
```text
# 출력 ↓ (user.email 등 민감하지 않은 범위에서, 토큰류는 노출 금지)
<!-- 붙여넣기 -->
```

```bash
# 저장소 초기화 및 첫 커밋
git init
git add .
git commit -m "feat: dev-workstation 초기 구성"

# GitHub 원격 연결 및 푸시
git remote add origin https://github.com/<본인계정>/<저장소명>.git
git branch -M main
git push -u origin main
```

**GitHub / VSCode 연동 증거:**

![VSCode GitHub 연동](docs/images/github-vscode.png)

> ⬜ VSCode에서 GitHub 로그인 + 저장소 연동 완료 화면을 캡처해 저장하세요.

---

## 13) 트러블슈팅

> 실제 겪은 문제를 2건 이상 기록하세요. (문제 → 원인 가설 → 확인 → 해결/대안)
> 아래는 **형식 예시**이므로 본인 사례로 교체합니다.

### 트러블슈팅 1 — (예시) 포트 충돌
- **문제**: `docker run -p 8080:80` 실행 시 `port is already allocated` 오류
- **원인 가설**: 이전 실습 컨테이너가 8080을 이미 점유
- **확인**: `docker ps` 로 8080 사용 컨테이너 발견
- **해결/대안**: 기존 컨테이너 종료(`docker rm -f <name>`) 또는 다른 host 포트(8081) 사용

### 트러블슈팅 2 — ⬜ (본인 사례)
- **문제**: ⬜
- **원인 가설**: ⬜
- **확인**: ⬜
- **해결/대안**: ⬜

---

## 14) 학습 목표 자가 점검

> 과제 목표: 아래를 스스로 설명할 수 있어야 함. 본인 언어로 채우세요.

1. **절대 경로 vs 상대 경로** — ⬜ (예시 포함)
2. **파일 권한 r/w/x 와 755·644 해석** — ⬜
3. **기존 Dockerfile 기반 커스텀 이미지 만들기** — ⬜
4. **포트 매핑이 필요한 이유** — ⬜
5. **Docker 볼륨(영속 데이터)** — ⬜
6. **Git vs GitHub (로컬 버전관리 vs 원격 협업)** — ⬜

---

## 🎁 보너스 (선택)

- [ ] Docker Compose 단일 서비스 (`docker compose up -d --build` → `docker compose ps/logs/down`)
- [ ] 환경 변수로 설정 분리 (`APP_ENV`)
- [ ] GitHub SSH 키 등록 및 푸시

```bash
# Compose 기본 흐름
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose down
```

---

## 🔒 보안 체크

- [ ] 로그/스크린샷에 토큰·비밀번호·개인키·인증코드 없음 (마스킹 완료)
- [ ] `.env`, `*.key`, `*token*` 은 `.gitignore` 로 커밋 제외
