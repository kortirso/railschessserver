$(function() {
    gameID = $('#board').data("game");
    PrivatePub.subscribe("/games/" + gameID + "/turns", function(data, channel) {
        turn = $.parseJSON(data.turn);
        figure = $('.square-' + turn.from + ' img');
        newFigure = $(figure).clone();
        $('.square-' + turn.to + ' img').remove();
        $('.square-' + turn.to).append(newFigure);
        figure.remove();
        $('#notice').html('');
    });
});