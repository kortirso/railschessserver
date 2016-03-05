$(function() {
    gameID = $('#board').data("game");

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
});