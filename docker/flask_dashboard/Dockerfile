FROM python:3.10-slim-bullseye

# ENV REDIS_URL redis://redis:6379/1
ENV MONGO_URL mongodb://mongo:27017/

ENV CELERY_BROKER_URL redis://redis:6379/0
ENV CELERY_RESULT_BACKEND redis://redis:6379/0

ENV FLASK_HOST 0.0.0.0
ENV FLASK_PORT 5000
ENV FLASK_DEBUG false

COPY . /app
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

CMD python flask_base.py
