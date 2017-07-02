import React from 'react';
import ReactDOMServer from 'react-dom/server';

class Board extends React.Component {

    constructor() {
        super();
        this.state = {
            game: {}
        }
    }

    componentDidMount() {
        this._fetchFigures();
    }

    _fetchFigures() {
        $.ajax({
            method: 'GET',
            url: `/api/v1/games/${this.props.game_id}.json?access_token=${this.props.access_token}`,
            success: (data) => {
                this.setState({game: data});
            }
        });
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
        if(line & 1) block = ['white', 'black'];
        else block = ['black', 'white'];
        return ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map((item, index) => {
            if(index & 1) color = block[0];
            else color = block[1];
            return (
                <div className={['square', color, 'square-' + item + line].join(' ')} key={index}></div>
            )
        });
    }

    _setFigures() {
        let parent = this;
        let child;
        if(this.state.game.figures) {
            $.each(this.state.game.figures, function(figure, data) {
                $('.square-' + data.cell).addClass('with_figure figure-' + data.color + data.type);
            });
        }
    }

    render() {
        return (
            <div id='all_board'>
                <div id='board'>
                    {this._prepareCells()}
                    {this._setFigures()}
                </div>
            </div>
        )
    }
}

export default Board;