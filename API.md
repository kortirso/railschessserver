# Ruby on Rails chess server API.

1. Sign Up at _http://chess-battle.ru_.
2. To create application at server visit _http://chess-battle.ru/oauth/applications_.
3. Click _New application_.
4. Fill _Name_ and _Redirect URI_.
5. Remember _application ID_ and _secret_.
6. Click _Authorized_.
7. You get _Authorization code_.
8. Send POST to `http://chess-battle.ru/oauth/token` with header `Content-Type: application/x-www-form-urlencoded` and raw body as `client_id=your_application_id46&client_secret=your_secret&code=your_authorization_code&grant_type=authorization_code&redirect_uri=your_redirect`.
9. At response you will get json with access_token.

## You can use next queries:

#### Current user information

`http://chess-battle.ru/api/v1/profiles/me.json?access_token=your_token`

_Answer_

`{"user":{"id":8,"username":"testing","elo":989}}`

#### All users information

`http://chess-battle.ru/api/v1/profiles/all.json?access_token=your_token`

_Answer_

`{"profiles":[{"id":2,"username":"First_user","elo":1118},{"id":3,"username":"Second_user","elo":1000},{"id":5,"username":"kortirso","elo":1000},{"id":7,"username":"tester","elo":1000}]}`