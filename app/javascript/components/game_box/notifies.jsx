import React from 'react';

class Notifies extends React.Component {

    render() {
        let game = this.props.game;
        return (
            <div id='turns' className='row data-block'>
                <p>Game Notation</p>
            </div>
        )
    }
}

export default Notifies;