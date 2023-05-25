FROM golang:1.20 as build
RUN mkdir -p /app/building
WORKDIR /app/building
ADD . /app/building
RUN --mount=type=cache,target=/root/.cache/go-build \
  GOPROXY=https://goproxy.cn make build

FROM debian:stable-slim
RUN chmod 777 /tmp && apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates  \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

# Copy from docker build
COPY --from=build /app/building/dist/bin/discovery /app/bin/
COPY --from=build /app/building/dist/conf/discovery.toml /app/conf/
# Copy from local build
#ADD  dist/ /app/
ENV  LOG_DIR    /app/log
EXPOSE 7171
WORKDIR /app/
CMD  /app/bin/discovery -conf /app/conf
