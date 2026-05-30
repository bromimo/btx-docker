FROM nginx:1.27-alpine AS builder

RUN apk add --no-cache \
    gcc g++ libc-dev make cmake pcre-dev zlib-dev openssl-dev \
    git curl

# Версия nginx берётся из образа, чтобы .so совпадала при обновлениях тега
RUN NGINX_VERSION=$(nginx -v 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') \
    && curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o /tmp/nginx.tar.gz \
    && tar -xzf /tmp/nginx.tar.gz -C /tmp \
    && git clone --recurse-submodules https://github.com/google/ngx_brotli.git /tmp/ngx_brotli \
    && cd /tmp/ngx_brotli/deps/brotli && mkdir out && cd out \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF .. \
    && make -j$(nproc) \
    && cd /tmp/nginx-${NGINX_VERSION} \
    && ./configure --with-compat --add-dynamic-module=/tmp/ngx_brotli \
    && make modules \
    && cp objs/ngx_http_brotli_filter_module.so /tmp/brotli_filter.so \
    && cp objs/ngx_http_brotli_static_module.so /tmp/brotli_static.so

FROM nginx:1.27-alpine
COPY --from=builder /tmp/brotli_filter.so /etc/nginx/modules/ngx_http_brotli_filter_module.so
COPY --from=builder /tmp/brotli_static.so /etc/nginx/modules/ngx_http_brotli_static_module.so

COPY nginx.conf /etc/nginx/nginx.conf
COPY btk.conf /etc/nginx/conf.d/default.conf
