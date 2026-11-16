# ─────────────────────────────────────────────────────────────
# 커스텀 이미지: nginx 베이스 + 정적 콘텐츠 교체 방식 (옵션 A)
# ─────────────────────────────────────────────────────────────
FROM nginx:alpine

# 이미지 메타데이터 (커스텀 포인트 1: 라벨 추가)
LABEL org.opencontainers.image.title="my-custom-nginx"
LABEL org.opencontainers.image.description="Codyssey dev-workstation mission web server"
LABEL org.opencontainers.image.version="1.0"

# 커스텀 포인트 2: 환경 변수 주입
ENV APP_ENV=dev

# 커스텀 포인트 3: 정적 콘텐츠 교체 (내가 만든 site/ 를 웹 루트로 복사)
COPY site/ /usr/share/nginx/html/

# 문서화 목적의 포트 노출 (실제 매핑은 docker run -p 로 수행)
EXPOSE 80

# 커스텀 포인트 4: 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1
