# 개발 워크스테이션 구축 (Dev Workstation)

> 입학연수 1과제 — 터미널 · Docker · Git/GitHub 기반 재현 가능한 개발 환경 구축
>
> 이 README 하나만 읽어도 전체 수행 내용과 검증 결과를 파악할 수 있도록 작성되었습니다.

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
    └── images/            # 스크린샷 증거
```

---

## 2) 실행 환경

| 항목 | 값 |
|------|-----|
| OS | Windows + WSL2 (Ubuntu) |
| 컨테이너 런타임 | Docker Desktop (Docker Engine 내장) |
| Shell / 터미널 | bash |
| Docker 버전 | 29.9.3 (build 5457199) |
| Git 버전 | 2.43.0 |

![버전 확인](docs/images/02-versions.png)

> 서울캠퍼스 sudo 제약 환경에서는 OrbStack을 쓰지만, 본 실습 PC는 Windows + WSL2 환경이라 Docker Desktop을 사용했습니다. Docker Desktop 실행 시 Docker 엔진이 함께 구동되며 WSL 터미널에서 `docker` 명령을 동일하게 사용합니다.

---

## 3) 수행 항목 체크리스트

- [x] Docker 설치/점검 (`docker --version`, `docker info`)
- [x] 기본 운영 명령 (`images` / `ps` / `logs` / `stats`)
- [x] `hello-world` 실행
- [x] Dockerfile 기반 커스텀 이미지 빌드/실행
- [x] 포트 매핑 접속 성공 (2회, 포트 2개)
- [x] 바인드 마운트 변경 반영 확인
- [x] Docker 볼륨 영속성 확인 (컨테이너 삭제 전/후)
- [x] Git 사용자/기본 브랜치 설정 + `git config --list`
- [x] GitHub 저장소 연동 및 push
- [x] 터미널 기본 조작 및 폴더 구성 로그 정리
- [x] 파일/디렉토리 권한 변경 실습 (변경 전/후 비교)
- [x] ubuntu 컨테이너 진입 및 attach/exec 관찰

---

## 4) 터미널 조작 로그

현재 위치 확인, 생성/이동, 복사, 이름변경, 삭제, 내용 확인을 수행했다.

```bash
$ cd ~
$ mkdir practice
$ cd practice
$ ls -la
total 8
drwxr-xr-x 2 developer developer 4096 Nov 16 19:28 .
drwxr-x--- 8 developer developer 4096 Nov 16 19:28 ..
$ touch sample.txt                  # 빈 파일 생성
$ cp sample.txt sample_copy.txt     # 복사
$ mv sample_copy.txt renamed.txt    # 이름변경
$ rm renamed.txt                    # 삭제
$ echo "hello codyssey" > sample.txt
$ cat sample.txt                    # 내용 확인
hello codyssey
```

---

## 5) 권한(Permission) 실습

파일 1개, 디렉토리 1개에 대해 권한을 변경하고 전/후를 비교했다.

```bash
$ chmod 600 perm_file.txt ; chmod 700 perm_dir       # (의도적으로 다른 값에서 시작)
$ echo "=== 변경 전 ===" ; ls -l perm_file.txt ; ls -ld perm_dir
=== 변경 전 ===
-rw------- 1 developer developer    0 Nov 16 19:33 perm_file.txt
drwx------ 2 developer developer 4096 Nov 16 19:33 perm_dir
$ chmod 644 perm_file.txt ; chmod 755 perm_dir
$ echo "=== 변경 후 ===" ; ls -l perm_file.txt ; ls -ld perm_dir
=== 변경 후 ===
-rw-r--r-- 1 developer developer    0 Nov 16 19:33 perm_file.txt
drwxr-xr-x 2 developer developer 4096 Nov 16 19:33 perm_dir
```

| 대상 | 변경 전 | 변경 후 | 의미 |
|------|---------|---------|------|
| `perm_file.txt` | `rw-------` (600) | `-rw-r--r--` (644) | 소유자 읽기·쓰기 / 그 외 읽기 |
| `perm_dir` | `rwx------` (700) | `drwxr-xr-x` (755) | 소유자 전체 / 그 외 읽기·실행 |

> 권한값은 r=4·w=2·x=1의 합. 644=rw/r/r, 755=rwx/rx/rx. 디렉토리는 안으로 들어가려면 `x`가 필요해 755를 쓴다.

> 변경 전(`rw-------`/`rwx------`)과 변경 후(`rw-r--r--`/`rwxr-xr-x`)가 달라진 것을 확인했다.

---

## 6) Docker 설치 및 기본 점검

```bash
docker --version
docker info
```

**Client / 플러그인**
![docker info client](docs/images/06-docker-info-client.png)

**Server (엔진 동작 확인)** — `Server Version: 29.9.3`, `Storage Driver: overlay2`, `Cgroup Version: 2`, `OSType: linux`
![docker info server](docs/images/06-docker-info-server.png)

---

## 7) Docker 기본 운영 명령

```bash
docker logs <컨테이너명>
docker stats --no-stream
```

**로그 (nginx 기동 + 접속 기록)**
![docker logs](docs/images/07-docker-logs.png)

**리소스 사용량**
![docker stats](docs/images/07-docker-stats.png)

> `docker images` / `docker ps` 증거는 9번·10번 섹션의 스크린샷에 함께 포함되어 있습니다.

---

## 8) 컨테이너 실행 실습

### 8-1. hello-world
```bash
docker run hello-world
```
![hello-world](docs/images/08-hello-world.png)

### 8-2. ubuntu 진입 후 명령
```bash
$ docker run -it ubuntu bash
root@a9720797595b:/# ls /
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@a9720797595b:/# echo "inside container"
inside container
root@a9720797595b:/# cat /etc/os-release | head -2
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
root@a9720797595b:/# exit
```

### 8-3. attach vs exec / 종료·유지 차이
```bash
# run -it 의 메인 프로세스(bash)를 exit → 컨테이너 종료
$ docker ps -a | head
CONTAINER ID   IMAGE         COMMAND    STATUS
a9720797595b   ubuntu        "bash"     Exited (0) 7 seconds ago     wizardly_hypatia

# 백그라운드 컨테이너는 exec 로 들어갔다 나와도 유지
$ docker run -d --name tmp ubuntu sleep infinity
$ docker exec -it tmp bash        # 들어가서 exit
$ docker ps | grep tmp            # (호스트에서) 여전히 Up 상태
073b6ab63551   ubuntu   "sleep infinity"   Up 8 minutes   tmp
$ docker rm -f tmp                # 정리
tmp
```

**관찰 요약**: 컨테이너는 "메인 프로세스가 살아있는 동안"만 유지된다. `docker run -it`의 메인 프로세스인 bash를 `exit`하면 컨테이너가 종료되지만(`Exited`), `sleep infinity`로 떠 있는 컨테이너에 `docker exec`로 들어가 연 쉘을 `exit`하면 그 쉘만 끝나고 컨테이너는 계속 Up 상태를 유지한다. (`docker ps`/`docker rm` 같은 호스트 명령은 컨테이너 내부가 아니라 호스트 터미널에서 실행해야 한다.)

---

## 9) 커스텀 이미지 제작 (Dockerfile)

**선택한 베이스**: `nginx:alpine` (옵션 A — 웹 서버 베이스 + 정적 콘텐츠 교체)

| 커스텀 포인트 | 목적 |
|--------|------|
| `LABEL` 메타데이터 | 이미지 식별/문서화 |
| `ENV APP_ENV=dev` | 환경 변수로 실행 모드 분리 |
| `COPY site/ ...` | 내가 만든 정적 콘텐츠로 기본 페이지 교체 |
| `HEALTHCHECK` | 컨테이너 상태 점검 자동화 |

```bash
docker build -t my-web:1.0 .
docker images | grep my-web
```

**빌드 성공**
![docker build](docs/images/09-build.png)

**이미지 생성 확인** (`my-web  1.0  63MB`)
![docker images](docs/images/09-images.png)

---

## 10) 포트 매핑 및 접속 증거 (2회)

같은 이미지를 호스트 포트만 바꿔 2개 실행 → 격리된 컨테이너 + 포트 매핑 확인.

### 8080 포트
```bash
docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
docker ps
curl http://localhost:8080
```
![8080 실행/ps/curl](docs/images/10-run-8080-terminal.png)

**브라우저 접속 (주소창 `localhost:8080` 포함)**
![browser 8080](docs/images/10-browser-8080.png)

### 8081 포트
```bash
docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
docker ps
curl http://localhost:8081
```
![8081 실행/ps/curl](docs/images/10-run-8081-terminal.png)

**브라우저 접속 (주소창 `localhost:8081` 포함)**
![browser 8081](docs/images/10-browser-8081.png)

---

## 11) 바인드 마운트 반영 + 볼륨 영속성

### 11-1. 바인드 마운트 (변경 즉시 반영)
```bash
docker run -d -p 8082:80 -v "$(pwd)/site:/usr/share/nginx/html:ro" --name my-web-mount my-web:1.0
```
![mount 실행 (컨테이너 3개 동시 가동)](docs/images/11-mount-run-terminal.png)

**변경 전** — `localhost:8082`
![mount before](docs/images/11-mount-before.png)

**파일 수정** — `site/index.html`의 `<h1>` 문구 교체 (재빌드 없음)
```bash
sed -i 's|<h1>.*</h1>|<h1>바인드 마운트 반영 성공! 🎉</h1>|' site/index.html
curl http://localhost:8082 | grep h1
```
![mount edit](docs/images/11-mount-edit-terminal.png)

**변경 후** — 새로고침만으로 반영됨
![mount after](docs/images/11-mount-after.png)

> 이미지는 그대로인데 호스트 파일만 고쳐도 실행 중 컨테이너에 즉시 반영 → "코드 수정 → 즉시 확인" 개발 흐름의 기반.

### 11-2. Docker 볼륨 (영속성)
```bash
docker volume create mydata
docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
docker exec vol-test bash -lc "echo hi > /data/hello.txt && cat /data/hello.txt"   # hi
docker rm -f vol-test                                                              # 컨테이너 삭제
docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
docker exec vol-test2 bash -lc "cat /data/hello.txt"                               # hi (유지됨!)
```
![volume persistence](docs/images/11-volume-persist.png)

> ✅ 컨테이너를 삭제해도 볼륨 데이터가 유지됨을 확인 (이미지/컨테이너와 데이터의 분리).

---

## 12) Git 설정 및 GitHub 연동

```bash
git config --global user.name "..."
git config --global user.email "..."
git config --global init.defaultBranch main
git config --list
```
![git config](docs/images/12-git-config.png)

```bash
git init
git add .
git commit -m "feat: dev-workstation 개발 워크스테이션 구축 산출물"
git remote add origin https://github.com/JINU7789/E1-1.git
git branch -M main
git push -u origin main
```
![git push](docs/images/12-git-push.png)

> 보안: 토큰/비밀번호 등 민감정보는 로그·스크린샷에 포함하지 않았습니다.

### VSCode ↔ GitHub 연동)
![github vscode](docs/images/14-github-vscode.png.png)

---

## 13) 트러블슈팅

### 트러블슈팅 1 — Docker 데몬 연결 실패
- **문제**: `docker run hello-world` 실행 시 `failed to connect to the docker API ... dockerDesktopLinuxEngine` 오류
- **원인 가설**: Docker CLI는 있으나 엔진(데몬)이 실행되지 않음
- **확인**: 에러 메시지의 `dockerDesktopLinuxEngine` 경로 / `docker info` 의 Server 미응답
- **해결**: Docker Desktop을 실행해 엔진 기동 → `docker info` Server 정상 → hello-world 성공

![daemon error](docs/images/13-daemon-error.png)

### 트러블슈팅 2 — 볼륨에 데이터가 없다고 나옴
- **문제**: 볼륨 영속성 테스트 마지막에 `cat: /data/hello.txt: No such file or directory`
- **원인 가설**: 데이터를 **기록하는 명령(`echo hi > ...`)을 건너뛰고** 컨테이너를 삭제함 (볼륨엔 쓴 적 없음)
- **확인**: 실행 순서를 되짚어 쓰기 단계 누락 발견
- **해결**: 쓰기 → 삭제 → 재연결 순서를 지켜 재실행하니 `hi` 유지 확인 (11-2 스크린샷)

---

## 14) 학습 목표 자가 점검

1. **절대 경로 vs 상대 경로**: 절대 경로는 루트(`/`)부터 전체 위치를 적어 어디서 실행하든 같은 곳을 가리킨다(예: `/home/developer/myproject`). 상대 경로는 현재 위치 기준이다(현재 폴더의 `site/index.html`, 상위로 가는 `../`). 스크립트의 이식성을 위해 상황에 맞게 사용한다.

2. **파일 권한 r/w/x 와 755·644 해석**: 권한은 소유자/그룹/기타 3묶음이며 r=4·w=2·x=1의 합으로 표기한다. 644 = `rw-(6)/r--(4)/r--(4)`, 755 = `rwx(7)/r-x(5)/r-x(5)`. 파일은 보통 644, 디렉토리와 실행 파일은 진입·실행에 `x`가 필요해 755를 준다. (5번 실습에서 600→644, 700→755로 직접 확인)

3. **기존 Dockerfile 기반 커스텀 이미지 만들기**: `FROM nginx:alpine`처럼 공식 베이스 이미지를 출발점으로 삼아 `COPY`로 내 정적 콘텐츠를 넣고 `ENV`·`LABEL`·`HEALTHCHECK`를 추가한 뒤 `docker build -t my-web:1.0 .`로 내 이미지를 만들었다. 베이스를 재사용하므로 처음부터 만들 필요가 없다.

4. **포트 매핑이 필요한 이유**: 컨테이너는 격리돼 있어 내부 포트(80)가 호스트에서 바로 보이지 않는다. `-p 8080:80`으로 호스트 8080 → 컨테이너 80을 연결해야 브라우저로 접속할 수 있다. 호스트 포트만 바꾸면 같은 이미지를 여러 개 동시에 띄울 수 있다(8080·8081에서 확인).

5. **Docker 볼륨(영속 데이터)**: 컨테이너를 삭제하면 내부 데이터는 사라지지만, 볼륨(`mydata`)에 저장한 데이터는 컨테이너와 분리돼 유지된다. 컨테이너를 지우고 새로 만들어 같은 볼륨을 붙여도 `hi`가 그대로 남아있음을 확인했다. 데이터와 실행 환경을 분리하는 수단이다.

6. **Git vs GitHub**: Git은 내 컴퓨터에서 변경 이력을 관리하는 버전관리 도구(로컬 커밋)이고, GitHub는 그 저장소를 원격에 올려 공유·협업하는 플랫폼이다. `git commit`은 로컬 기록, `git push`는 GitHub 원격으로 올리는 작업이다.

---

## 🎁 보너스 (선택)
- [ ] Docker Compose 단일 서비스 (`docker compose up -d --build` → `ps/logs/down`)
- [ ] 환경 변수로 설정 분리 (`APP_ENV`)
- [ ] GitHub SSH 키 등록 및 push

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose down
```

---

## 🔒 보안 체크
- [x] 로그/스크린샷에 토큰·비밀번호·개인키·인증코드 없음
- [x] `.env`, `*.key`, `*token*`, `*:Zone.Identifier` 은 `.gitignore` 로 커밋 제외
