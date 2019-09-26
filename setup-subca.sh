#!/bin/bash


TARGET_DIR=$PWD/$1
NAME=$1

# Tạo thư mục subca và các thư mục cần thiết
mkdir $TARGET_DIR
cd $TARGET_DIR
#cp ../setup-clientca.sh .

# Tạo các thư mục để lưu chứng chỉ, chưa chứng chỉ yêu cầu và kháo cho subca
mkdir certs crl csr newcerts pfx private
chmod 700 private 
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber


# Tạo file config openssl.cnf cho subca


echo "[ ca ]
default_ca = CA_default

[ CA_default ]

# Directory and file locations.
dir               = $TARGET_DIR
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

# The root key and root certificate.
private_key       = \$dir/private/$NAME.key.p12
certificate       = \$dir/certs/$NAME.cert.crt

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/$NAME.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = supplied

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = VN 
stateOrProvinceName_default     = HN
localityName_default            = HN
0.organizationName_default      = KMA Ltd
organizationalUnitName_default  = KMA Ltd Certificate Authority
emailAddress_default            = anpnvt@gmail.com

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ crl_ext ]
authorityKeyIdentifier=keyid:always
[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
" > openssl.cnf

# Tạo khóa cho Sub Ca

openssl genrsa -aes256 -out private/$NAME.key.p12 4096

echo -e "Tao thành công subca key\n"

# Tạo certificate singing request (CSR)

echo -e "Tạo csr cho subca\n"
openssl req -config openssl.cnf -new -sha256 -key private/$NAME.key.p12 -out csr/$NAME.csr

echo -e "Tạo thành công csr\n"

# Quay lại thư mục chưa cấu hình root ca để tạo chứng chỉ cho sub ca 
cd ..

# Tạo Certificate subca
echo -e "Tạo chứng chỉ cho sub ca\n"
openssl ca \
	-config openssl.cnf \
	-extensions v3_sub_ca \
	-days 3650 -notext -md sha256 \
	-in $NAME/csr/$NAME.csr \
	-out $NAME/certs/$NAME.cert.crt

echo -e "Kiểm tra chứng chỉ của subca\n"
openssl verify -CAfile certs/rootca.cert.crt $TARGET_DIR/certs/$NAME.cert.crt
