import React from 'react';

class Board extends React.Component {

    constructor() {
        super();
        this.state = {
            status: 0,
            figure: {},
            from: '',
            to: ''
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
        if(line & 1) block = ['white', 'black'];
        else block = ['black', 'white'];
        return ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map((item, index) => {
            if(index & 1) color = block[0];
            else color = block[1];
            return (
                <div id={item + line} className={['square', color].join(' ')} onClick={this._handleClick.bind(this, item + line)} key={index}></div>
            )
        });
    }

    _handleClick(clickedId, object) {
        let clicked = object.target;
        console.log(clicked);
        if (this.state.status == 0) {
            if (clicked.classList.contains('with_figure')) {
                $('#' + clickedId).addClass('yellow');
                this.setState({status: 1, from: clickedId, figure: clicked.classList[3]});
            }
        } else if (this.state.status == 1) {
            $('#' + this.state.from).removeClass('yellow with_figure ' + this.state.figure);
            $('#' + clickedId).addClass('with_figure ' + this.state.figure);
            this.setState({status: 0, from: '', figure: {}});
            // todo: send request to backend, set new game status
            //var audio = new Audio('<%= asset_path("turn.wav") %>');
            //audio.play();
        }
    }

    _setFigures() {
        let parent = this;
        let child;
        $.each(this.props.game.figures, function(figure, data) {
            $('#' + data.cell).addClass('with_figure figure-' + data.color + data.type);
        });
    }

    render() {
        console.log(this.props.game);
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