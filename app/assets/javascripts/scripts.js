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
        $('#next_turn').html(turn.next_turn);
        $('#notice').html('');
        $('#turn_from').val('');
        $('#turn_to').val('');
    });
});