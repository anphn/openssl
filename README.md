# Script tạo lập chứng chỉ rootca, subca, chứng thư cho người dùng sử dụng openssl 

## Usage 

```bash 
# create a CA
./setup-rootca.sh root-ca
# change the current folder
cd root-ca
# create an intermediate CA
./setup-subca.sh subca
# change the current folder
cd subca
# create a server certificate
./setup-clientca.sh test.example.com
# create a client certificate
./setup-clientca.sh anpn 


```
