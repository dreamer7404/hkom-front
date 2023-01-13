import React from 'react';
import { useDispatch, useSelector } from 'react-redux';

const Test01 = () => {

    // const {number, diff} = useSelector(state => state.counter);
    const counter = useSelector(state => state.counter);

    return (
        <div>
            test01...{counter.number}
        </div>
    )
};
export default Test01;