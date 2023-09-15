FROM python:3.10-slim-bullseye

COPY . /app
WORKDIR /app

RUN apt-get update && apt-get install python-dev -y && apt-get install g++ -y && apt-get install gcc -y
RUN python setup.py build

FROM python:3.10-slim-bullseye

COPY --from=0 /app/build/lib.linux*/* /app/
