#!/bin/bash

if [ -z "$REDIRECT_TARGET" ]; then
	echo "Redirect target variable not set (REDIRECT_TARGET)"
	exit 1
else
	# Add http if not set
	if ! [[ $REDIRECT_TARGET =~ ^https?:// ]]; then
		REDIRECT_TARGET="https://$REDIRECT_TARGET"
	fi

	# Add trailing slash
	# if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
	# 	REDIRECT_TARGET="$REDIRECT_TARGET/"
	# fi
fi

# Default to 443
#LISTEN="443"
# Listen to PORT variable given on Cloud Run Context
#if [ ! -z "$PORT" ]; then
#	LISTEN="$PORT"
#fi

cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen 80;
	listen 443 ssl;

	server_name $VIRTUAL_HOST;

	ssl_certificate     /etc/nginx/certs/$VIRTUAL_HOST.crt;
    ssl_certificate_key /etc/nginx/certs/$VIRTUAL_HOST.key;
	ssl_trusted_certificate /etc/nginx/certs/$VIRTUAL_HOST.chain.pem;
  
	location / {
		proxy_pass ${REDIRECT_TARGET};
	}
}
EOF


echo "Redirecting HTTPS requests to ${REDIRECT_TARGET}..."

exec nginx -g "daemon off;"
