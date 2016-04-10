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

`GET http://chess-battle.ru/api/v1/profiles/me.json?access_token=your_token`

`{"user":{"id":8,"username":"testing","elo":989}}`

#### All users information

`GET http://chess-battle.ru/api/v1/profiles/all.json?access_token=your_token`

`{"profiles":[{"id":2,"username":"First_user","elo":1118},{"id":3,"username":"Second_user","elo":1000},{"id":5,"username":"kortirso","elo":1000},{"id":7,"username":"tester","elo":1000}]}`

#### List of challenges

`GET http://chess-battle.ru/api/v1/challenges.json?access_token=your_token`

`{"challenges":[{"id":163,"user_id":8,"opponent_id":5,"color":"random","access":true,"created_at":"2016-03-24T13:18:58.523Z","updated_at":"2016-03-24T13:18:58.523Z"},{"id":164,"user_id":8,"opponent_id":null,"color":"random","access":true,"created_at":"2016-03-24T13:20:31.119Z","updated_at":"2016-03-24T13:20:31.119Z"}]}`

#### List of challenges

`POST http://chess-battle.ru/api/v1/challenges/create.json?access_token=your_token`

`Parameters: {"challenge"=>{"access"=>"1", "opponent_id"=>"", "color"=>"random"}}`

`access - 0 or 1, color - white, black or random, opponent_id - empty or user_id`

`Success answer - {"challenges":[{"id":163,"user_id":8,"opponent_id":5,"color":"random","access":true,"created_at":"2016-03-24T13:18:58.523Z","updated_at":"2016-03-24T13:18:58.523Z"},{"id":164,"user_id":8,"opponent_id":null,"color":"random","access":true,"created_at":"2016-03-24T13:20:31.119Z","updated_at":"2016-03-24T13:20:31.119Z"}]}`

`Error answer - 'User does not exist;Error access parameter, must be 1 or 0;Error color parameter, must be white, black or random'`