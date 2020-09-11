FROM python:3-alpine AS base

FROM base AS builder

WORKDIR /usr/src/app

COPY requirements.txt ./

# Build Dependencies
RUN apk --no-cache add gcc musl-dev libffi-dev openssl-dev libxml2-dev libxslt-dev file llvm-dev make g++

# Python Dependencies
RUN pip install --no-cache-dir --prefix=/install wheel cryptography gunicorn pymysql
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime Environment Image
FROM base AS runtime

WORKDIR /usr/src/app

# Runtime Dependencies
RUN apk --no-cache add libxml2 libxslt
COPY --from=builder /install /usr/local

COPY . .

RUN flask db init \
  && flask db migrate \
  && flask db upgrade

CMD flask db upgrade \
  && gunicorn -b 0.0.0.0:5000 -w 4 yotter:app

EXPOSE 5000
