## Ruby on Rails chess server

RailsChessServer deployed at DigitalOcean - <http://chess-battle.ru>.
You can visit it, play chess and have fun.

####To install application you need run commands:

1. _git clone https://github.com/kortirso/railschessserver.git_.
2. _cd railschessserver_.
3. _bundle install_.
4. rename application.yml.example to application.yml and fill with your secrets.
5. _rake db:create_.
6. _rake db:schema:load_.
7. In _db/seeds.rb_ set password for AI player and run _rake db:seed_.

####To launch application:

1. In project folder run _rails s_.
2. In project folder run rackup private_pub.ru -s thin -E production.
3. Open http://localhost:3000.
    
####Discussion / Feedback / Issues / Bugs

For general discussion and questions, you can use topic at forum <http://onrails.club/t/praktika-dlya-novichkov-shahmatnyj-server-chess-battle/822/4>.

If you've found a genuine bug or issue, please use the Issues section on github <https://github.com/kortirso/railschessserver/issues>.

####Contribution

Thanks to all contributors who have made it even better: <https://github.com/kortirso/railschessserver/contributors>.