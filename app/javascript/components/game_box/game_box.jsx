import React from 'react';
import Board from 'components/game_box/board';
import Stats from 'components/game_box/stats';
import Turns from 'components/game_box/turns';
import Notifies from 'components/game_box/notifies';

class GameBox extends React.Component {

    constructor() {
        super();
        this.state = {
            game: {}
        }
    }

    componentWillMount() {
        this._fetchGame();
    }

    _fetchGame() {
        $.ajax({
            method: 'GET',
            url: `/api/v1/games/${this.props.game_id}.json`,
            success: (data) => {
                this.setState({game: data});
            }
        });
    }

    render() {
        return (
            <div id='game_box' className='row'>
                <div className='col-xs-12 col-md-6'>
                    <Board game={this.state.game} access_token={this.props.access_token} />
                </div>
                <div className='col-xs-12 col-md-3'>
                    <Stats game={this.state.game} />
                    <Turns game={this.state.game} />
                </div>
                <div className='col-xs-12 col-md-3'>
                    <Notifies game={this.state.game} />
                </div>
            </div>
        )
    }
}

export default GameBox;