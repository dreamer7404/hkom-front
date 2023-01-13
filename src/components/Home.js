import React from 'react';
import { useDispatch, useSelector } from 'react-redux';

const Home = () => {

    // const {number, diff} = useSelector(state => state.counter);
    const counter = useSelector(state => state.counter);

    return (
        <div style={{height: '700px', background: 'gray', marginTop: '80px'}}>
            Home...
        </div>
    )
};
export default Home;