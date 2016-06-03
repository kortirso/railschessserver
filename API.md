# Ruby on Rails chess server API.

## Get token with Authorization code:

1. Sign Up at _http://chess-battle.ru_.
2. To create application at server visit _http://chess-battle.ru/oauth/applications_.
3. Click _New application_.
4. Fill _Name_ and _Redirect URI_.
5. Remember _application ID_ and _secret_.
6. Click _Authorized_.
7. You get _Authorization code_.
8. Send POST to `http://chess-battle.ru/oauth/token` with header `Content-Type: application/x-www-form-urlencoded` and raw body as `client_id=YOUR_APPLICATION_ID&client_secret=YOUR_SECRET&code=YOUR_AUTHORIZATION_CODE&grant_type=authorization_code&redirect_uri=YOUR_REDIRECT`.
9. At response you will get json with access_token.

## Get token with Password:

1. Sign Up at _http://chess-battle.ru_.
2. Send POST to `http://chess-battle.ru/oauth/token` with header `Content-Type: application/x-www-form-urlencoded` and raw body as `grant_type=password&username=YOUR_USERNAME&password=YOUR_PASSWORD`.
3. At response you will get json with access_token.

## Get access to API description:

Visit _http://chess-battle.ru/apipie_.
