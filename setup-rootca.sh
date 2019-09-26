#!/bin/bash
# Tạo thư mục cần thiết cho Root CA

TARGET_DIR=$PWD/$1
mkdir $TARGET_DIR
cp -r setup-subca.sh $TARGET_DIR

cd $TARGET_DIR
# Tạo các thư mục để chưa khóa và chứng chỉ
mkdir certs crl newcerts private 

# Phân quyền cho thưc mục chứa khóa 
chmod 700 private 
	# File databases lưu thông tin của các chứng chỉ đã ký
touch index.txt
echo 1000 > serial

# File cấu hình openssl sử dụng để tạo chứng chỉ
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
private_key       = \$dir/private/rootca.key.p12
certificate       = \$dir/certs/rootca.cert.crt

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
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

[ v3_sub_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
" > openssl.cnf

echo -e "\nTạo khóa cho Root CA"

openssl genrsa -aes256 -out private/rootca.key.p12 4096

sleep 5

echo -e "\nTạo chứng chỉ cho RootCA\n."

openssl req -config openssl.cnf \
	-key private/rootca.key.p12 \
	-new -x509 -days 7300 -sha256 -extensions v3_ca \
	-out certs/rootca.cert.crt
