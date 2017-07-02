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
            <Board />
        )
    }
}

export default GameBox;