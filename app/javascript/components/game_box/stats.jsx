import React from 'react';

class Stats extends React.Component {

    _showPlayers(game) {
        let player_1, player_2;
        if (game.guest) {
            player_1 = 'Guest';
            player_2 = 'Koala Mike';
        } else if (game.user && game.opponent) {
            player_1 = game.user.username;
            player_2 = game.opponent.username;
        }
        return (
            <div>
                <p>White Player - {player_1}</p>
                <p>Black Player - {player_2}</p>
            </div>
        )
    }

    render() {
        let game = this.props.game;
        return (
            <div id='data' className='row data-block'>
                <p>Chess Game</p>
                <p>#{game.id}</p>
                {this._showPlayers(game)}
            </div>
        )
    }
}

export default Stats;