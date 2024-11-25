FROM python:3.9-alpine3.13
#light-weigth version of linux is alpine3.13
LABEL maintainer="oscar vazquez rueda"

ENV PYTHONUNBUFFERED = 1
#Not buffered the output, the output from python must print be
#printed directly

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
#Working directory where by default the commands will be run directly
EXPOSE 8000

ARG DEV=false
#Using less RUN commands it does not add many layers when creating the image
RUN python -m venv /py && \
#We use a virtual environment
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \    
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
       --disabled-password \
       --no-create-home \
       django-user

#UPdates the environment variable to not need to specify the whole path just run pip
ENV PATH="/py/bin:$PATH"

#Switch to the django user from root user
USER django-user
       