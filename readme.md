# Token Authentication in Auth0 using External Custom Social Connection
Setup explained in a [similar connection project for IP based authentication](https://github.com/abbaspour/auth0-ext-authz-ip).

## Sequence
![sequence diagram](./screenshots/sequence-diagram.png)
note: latest seq [here]().

### Test Against Social Connection
```bash
./tools/authorize.sh -d http://localhost:8081/auth/oauth \
    -H id_token=token1 \
    -c ${client_id} \
    -u ${redirectUris} \
    -s profile \
    -R code \
    -b firefox \
    -o
```
