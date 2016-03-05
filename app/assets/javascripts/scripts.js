$(function() {
    gameID = $('#board').data("game");
    userID = $('#current_games').data("user");

    PrivatePub.subscribe("/games/" + gameID + "/turns", function(data, channel) {
        turn = $.parseJSON(data.turn);
        figure = $('.square-' + turn.from + ' img');
        newFigure = $(figure).clone();
        $('.square-' + turn.to + ' img').remove();
        $('.square-' + turn.to).append(newFigure);
        figure.remove();
        if(turn.second_from != '0') {
            if(turn.second_to != '0') {
                figure = $('.square-' + turn.second_from + ' img');
                newFigure = $(figure).clone();
                $('.square-' + turn.second_to).append(newFigure);
                figure.remove();
            }
            else {
                $('.square-' + turn.second_from + ' img').remove();
            }
        }
        else if(turn.second_to != '0') {
            figure = $('.square-' + turn.second_to + ' img');
            newFigure = $(figure).clone();
            $('.square-' + turn.to + ' img').remove();
            $('.square-' + turn.to).append(newFigure);
        }
        $('#next_turn').html(turn.next_turn);
        $('#notice').html('');
        $('#turn_from').val('');
        $('#turn_to').val('');
        var audio = new Audio('../assets/turn.wav');
        audio.play();
    });

    PrivatePub.subscribe("/games/" + gameID, function(data, channel) {
        game = $.parseJSON(data.game);
        $('#result').html('');
        $('#result').append('<p>Партия завершилась</p>');
        $('#result').append('Результат - ' + game.game_result_text);
        $('#actions').remove();
    });

    PrivatePub.subscribe("/users/challenges", function(data, channel) {
        challenge = $.parseJSON(data.challenge);
        newFigure = $('#challenges table tbody .hidden td:first-child form').clone();
        $('#challenges table tbody').prepend('<tr class="challenge_' + challenge.id + '"><td>' + challenge.user.username + '</td><td><span class="rating_block">' + challenge.user.elo + '</span></td><td>' + challenge.color + '</td><td></td></tr>');
        if(challenge.user.id != userID) {
            $('#challenges table tbody tr:first-child td:last-child').append(newFigure);
            $('#challenges table tbody tr:first-child #game_challenge').attr("value", challenge.id);
        }
        else {
            $('#challenges table tbody tr:first-child td:last-child').append('<a class="btn btn-sm btn-default" data-remote="true" rel="nofollow" data-method="delete" href="/challenges/' + challenge.id + '">X</a>');
        }
    });

    PrivatePub.subscribe("/users/" + userID + "/challenges", function(data, channel) {
        challenge = $.parseJSON(data.challenge);
        newFigure = $('#challenges table tbody .hidden td:first-child form').clone();
        $('#challenges table tbody').prepend('<tr class="challenge_' + challenge.id + '"><td>' + challenge.user.username + '</td><td><span class="rating_block">' + challenge.user.elo + '</span></td><td>' + challenge.color + '</td><td></td></tr>');
        if(challenge.user.id != userID) {
            $('#challenges table tbody tr:first-child td:last-child').append(newFigure);
            $('#challenges table tbody tr:first-child #game_challenge').attr("value", challenge.id);
        }
        $('#challenges table tbody tr:first-child td:last-child').append('<a class="btn btn-sm btn-default" data-remote="true" rel="nofollow" data-method="delete" href="/challenges/' + challenge.id + '">X</a>');
    });

    PrivatePub.subscribe("/users/games", function(data, channel) {
        challenge = $.parseJSON(data.challenge);
        $('#challenges .challenge_' + challenge.id).remove();
    });

    PrivatePub.subscribe("/users/" + userID + "/games", function(data, channel) {
        game = $.parseJSON(data.game);
        $('#current_games h2').after('<div class="col-xs-6"><div class="game_block"><p>Партия №' + game.id + '</p><p>' + game.user.username + '<span class="rating_block">' + game.user.elo + '</span></p><p>' + game.opponent.username + '<span class="rating_block">' + game.opponent.elo + '</span></p><p><a class="btn btn-sm btn-default" href="/games/' + game.id + '">Посмотреть</a></p><div></div>');
    });
});