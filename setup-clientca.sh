#!/bin/bash

USER_NAME=${1// /_}
START_DATE=$2
END_DATE=$3

echo -e "Tạo khóa cho user $USER_NAME\n"
# openssl -aes256 genrsa -out private/$USER_NAME.key.p12 2048
openssl genrsa -out private/$USER_NAME.key.p12 2048

# chmod 400 private/$USER_NAME.key.p12

echo -e "Tạo yêu cầu ký chứng chỉ cho user: $USER_NAME\n "
openssl req -config openssl.cnf \
    -new -sha256 \
    -key private/$USER_NAME.key.p12 \
    -out csr/$USER_NAME.csr

echo -e "Tạo chứng chỉ cho user:$USER_NAME\n"
if ! ([ -z "$START_DATE" ] || [ -z "$END_DATE" ])    
then
    openssl ca \
        -config openssl.cnf \
        -extensions usr_cert \
        -startdate $START_DATE \
        -enddate $END_DATE \
        -notext \
        -md sha256 \
        -in csr/$USER_NAME.csr \
        -out certs/$USER_NAME.cert.crt
else
    openssl ca \
        -config openssl.cnf \
        -extensions usr_cert \
        -days 30 \
        -notext \
        -md sha256 \
        -in csr/$USER_NAME.csr \
        -out certs/$USER_NAME.cert.crt
fi

# chmod 444 certs/$USER_NAME.cert.p12

echo "Xác thực chứng chỉ"
openssl verify -CAfile certs/subca.cert.p12 certs/$USER_NAME.cert.crt

# Show the certificate
openssl x509 -noout -text -in certs/$USER_NAME.cert.crt   
