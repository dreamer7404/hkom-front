import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { getUsrMgmts } from '../../../store/sys';
import { Link } from 'react-router-dom';

const UsrMgmts = () => {

    const users = useSelector(state => state.sys.users && state.sys.users.data);
    const dispatch = useDispatch();

    useEffect(() => {
        dispatch(getUsrMgmts());
    }, [dispatch]);


    if(!users) return;

    return (
        <>
         <div>UsrMgmts...LENGTH: {users.data.length}  </div>
             <ul>
                
                {users.data.map((d,i) => (
                    <li key={i}>
                        <Link to={`/post/${d.userEeno}`}>{d.userEeno}</Link>
                    </li>
                ))} 
            </ul>
        </>
    )
}
export default UsrMgmts;