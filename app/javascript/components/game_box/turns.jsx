import React from 'react';

class Turns extends React.Component {

    render() {
        let game = this.props.game;
        return (
            <div id='result' className='row data-block'>
                <p>Turns</p>
            </div>
        )
    }
}

export default Turns;