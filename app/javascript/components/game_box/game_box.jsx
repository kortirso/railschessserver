import React from 'react';
import Board from 'components/game_box/board';

class GameBox extends React.Component {

    constructor() {
        super();
        this.state = {

        }
    }

    render() {
        return (
            <Board game_id={this.props.game_id} access_token={this.props.access_token} />
        )
    }
}

export default GameBox;