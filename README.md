# Тестовый КриптоПро 5 для SecurityVision (DEB-пакет)

## Инструкция:

### 1. Добавить 3 директории в проект
Положить 3 директории `crypto_cer`, `crypto_distr`, `crypto_src` с содержимым на одном уровне с файлом `docker-compose.yml` проекта SecurityVision
> Тестовые корневой и промежуточный сертификаты `rubca.cer`, `subca.cer` можно скачать по адресу: http://testca2012.cryptopro.ru/ui/

### 2. Добавить `volumes` в `docker-compose.yml`
В файле `docker-compose.yml` для SecurityVision добавить `volumes` в сервисе коннекторов:
```docker
volumes:
   - ./crypto_distr:/crypto_distr
   - ./crypto_src:/crypto_src
   - ./crypto_cer:/crypto_cer
```
### 3. Добавить `command` в `docker-compose.yml`
```docker
command: /bin/sh -c "/crypto_src/entrypoint.sh"
```

### 4. Пересобрать контейнер коннекторов
- Посмотреть запущенные контейнеры:  
```shell
docker ps
```
- Остановить контейнер:  
```shell
docker compose stop <container name>
```
- Пересобрать контейнер:  
```shell
docker-compose up -d --build --force-recreate --no-deps <container name>
```

### 5. Зайти в контейнер с коннекторами
```shell
docker compose exec -it <container name> /bin/bash
```

### 6. Добавить самоподписанный сертификат
Создать и добавить самоподписанный сертификат в директорию `crypto_cer`.
#### Пример получения сертификата:
- Выполнить команду на запрос сертификата:
```shell
/opt/cprocsp/bin/amd64/cryptcp -createrqst -sg -dn "C=RU,ST=Moscow,O=S-Terra Inc.,CN=user" -exprt -provtype 81 -cont '\\.\HDIMAGE\user' -certusage 1.3.6.1.5.5.7.3.2 ./user.csr.pem
```
- Посмотреть и скопировать содержимое полученного файла:
```shell
cat ./user.csr.pem
```
Пример ответа:
```
-----BEGIN NEW CERTIFICATE REQUEST-----
MIIBPTCB6XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXY293MRUwEwYD
XXXXXXXXXVRlcnJhIEluYy4xDjAMBgNVBAMTBXVzZXIxMGYwHwYIKXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ovp++XXXXXXXXXXXXXXXXXXm5UAufloe0PAMptZekkdnXXXXXXXXXXXXXzA1Bgor
XXXXXXXXXXXXXXXXJTATBgNVHSUEDDAKBggrBgXXXXXXXXXXXXXXXXXXXXXXXXXX
BsAwCgYIKoUXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXCWP544EM+Zx4Hojx4WSLJS
XN71UzBwx+y1qeTpXXXXXXXXXXXXXXXeRekfuFJjl/SW
-----END NEW CERTIFICATE REQUEST-----
```
- Отправить готовый запрос на получение тестового сертификата можно по ссылке https://www.cryptopro.ru/certsrv/certrqxt.asp
#### Дополнительные ссылки:
- https://www.cryptopro.ru/certsrv/
- https://www.cryptopro.ru/certsrv/certrqma.asp
- https://www.cryptopro.ru/certsrv/certcarc.asp

### 7. Положить тестовый сертификат в контейнер коннекторов
Скачать сертификат и положить его в контейнер.
```shell
docker cp <путь к файлу на хост машине> containerid:<путь к файлу в контейнере>
```

### 8. Установить тестовый сертификат внутри контейнера
```shell
certmgr -install -file /crypto_cer/<имя сертификата>
cryptcp -instcert -provtype 81 /crypto_cer/<имя сертификата>
```

### 9. Проверить подписание сертификата
> У сертификата должен быть `PrivateKey Link = Yes` иначе не подписывает

Примеры просмотра списка сертификатов:
```shell
certmgr -list
certmgr -list -store My
certmgr -list -store root
```
Подписать файл:
```shell
cryptcp -sign -thumbprint <id сертифиата> -uMy -der test.txt test.sig
```

### *10. Если entrypoint.sh не отработал
Зайти в контейнер:
````shell
docker compose exec -it <container name> /bin/bash
````
Внутри контейнера выполнить команды:
```shell
/crypto_distr/install.sh kc1
ln -s /opt/cprocsp/sbin/amd64/cpconfig /usr/bin/cpconfig
ln -s /opt/cprocsp/bin/amd64/certmgr /usr/bin/certmgr
ln -s /opt/cprocsp/bin/amd64/cryptcp /usr/bin/cryptcp
certmgr -install -store root -file /crypto_cer/rootca.cer
certmgr -install -file /crypto_cer/subca.cer
cp /crypto_src/certs_info /usr/bin/certs_info
chmod +x /usr/bin/certs_info
certs_info
apt-get update && apt-get install expect
```
