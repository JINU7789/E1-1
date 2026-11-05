FROM python:3.12

WORKDIR /app

# Flask 설치 추가!
RUN pip install flask

COPY . .

CMD ["python", "main.py"]