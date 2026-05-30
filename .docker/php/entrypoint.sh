#!/bin/sh
# Пробрасываем localhost:8080 → web:80 для теста сокетов Битрикс.
# site_checker.php берёт HOST/PORT из браузера (window.location), поэтому
# fsockopen('localhost', 8080) из PHP-контейнера иначе уходит в никуда.
socat TCP4-LISTEN:8080,fork,reuseaddr TCP:web:80 &

# Генерируем конфиг msmtp из переменных окружения
cat > /etc/msmtprc << EOF
defaults
auth off
tls off
logfile /var/log/msmtp.log

account default
host ${SMTP_HOST:-mail}
port ${SMTP_PORT:-1025}
from ${MAIL_FROM:-noreply@btk.local}
EOF
chmod 644 /etc/msmtprc

exec docker-php-entrypoint "$@"