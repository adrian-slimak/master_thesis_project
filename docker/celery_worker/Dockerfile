FROM mtp-simenv

# ENV REDIS_URL redis://redis:6379/1
ENV MONGO_URL mongodb://mongo:27017/

ENV CELERY_BROKER_URL redis://redis:6379/0
ENV CELERY_RESULT_BACKEND redis://redis:6379/0

COPY . /app
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt
