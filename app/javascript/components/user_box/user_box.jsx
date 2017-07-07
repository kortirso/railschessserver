import React from 'react';
import Friends from 'components/user_box/friends';
import Offer from 'components/user_box/offer';
import Challenges from 'components/user_box/challenges';

class UserBox extends React.Component {

    constructor() {
        super();
        this.state = {

        }
    }

    render() {
        return (
            <div className='col-xs-12 col-sm-6'>
                <div className='row'>
                    <Friends />
                </div>
                <div className='row'>
                    <Offer />
                </div>
                <div className='row'>
                    <Challenges />
                </div>
            </div>
        )
    }
}

export default UserBox;