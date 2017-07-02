import React from 'react';

class Board extends React.Component {

    constructor() {
        super();
        this.state = {

        }
    }

    _prepareCells() {
        let block;
        return [8, 7, 6, 5, 4, 3, 2, 1].map((item) => {
            return (
                <div className='chess_row' key={item}>
                    {this._prepareLine(item)}
                    <div className='clearfix'></div>
                </div>
            )
        });
    }

    _prepareLine(line) {
        let color;
        let block;
        if(line & 1) {
            block = ['white', 'black']
        } else {
            block = ['black', 'white']
        }
        return ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map((item, index) => {
            if(index & 1) {
                color = block[0]
            } else {
                color = block[1]
            }
            return (
                <div className={['square', color, 'square-' + item + line].join(' ')} key={index}></div>
            )
        });
    }

    render() {
        return (
            <div id='all_board'>
                <div id='board'>
                    {this._prepareCells()}
                </div>
            </div>
        )
    }
}

export default Board;