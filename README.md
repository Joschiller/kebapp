# kebapp

An application to create lunch groups and collect orders.

Users can create groups to collect orders for lunch breaks and view summaries of such orders.

Administrators can configure the available meals and their options as well as the permissions of users.

## Deployment

### Docker Network Setup

The compose file relies on an existing docker network.

To create the network run: `docker network create <name of the network>`

### Env

- generate a `passwords.yaml` at `./kebapp_server/config/passwords.yaml` based on the [example file](./kebapp_server/config/passwords.yaml.example)
- generate [kebapp_flutter/.env](./kebapp_flutter/.env) based on the [example file](./kebapp_flutter/.env.example)
- generate [kebapp_server/.env](./kebapp_server/.env) based on the [example file](./kebapp_server/.env.example)

### Reverse Proxy

To host the service, it is required to provide a separate reverse proxy.

The network of the docker service must be provided in the [kebapp_server/.env](./kebapp_server/.env).

The reverse proxy must be configured as follows:

- domain name: same value as SERVER_DOMAIN from [kebapp_flutter/.env](./kebapp_flutter/.env)
- scheme: http
- forward hostname: server
- forward port: 8080

## Contributing

To setup `serverpod` and install needed dependencies run `./dev.sh init`.

### Env

- generate a `passwords.yaml` at `./kebapp_server/config/passwords.yaml` based on the [example file](./kebapp_server/config/passwords.yaml.example)
- generate [kebapp_server/dev.env](./kebapp_server/dev.env) based on the [example file](./kebapp_server/dev.env.example)

### Useful Commands

- generate model and endpoints: `serverpod generate`
- create a migration: `serverpod create-migration`
- run application on a mobile device: `flutter run --dart-define=SERVER_URL=http://<host ip>:8080/`

### Testing the API via Postman

#### Retrieving Authentication Key

- URL: `http://localhost:8080/serverpod_auth.email`
- Body:
  ```json
  {
    "method": "authenticate",
    "email": "email",
    "password": "password"
  }
  ```

#### Creating Authorization-Header

Using the response from the authentication request, all following request can set their `authorization`-header.

The value must be created as follows:

1. Concatenate `keyId:key`
2. base64-encode the value
3. create the header `authorization` = `Basic base64-encoded-key`

#### Running Request

- URL: `http://localhost:8080/mealAdmin` (or other endpoint)
- `authorization`-header
- Body (optionally with further parameters):
  ```json
  {
    "method": "nameOfMethod"
  }
  ```
