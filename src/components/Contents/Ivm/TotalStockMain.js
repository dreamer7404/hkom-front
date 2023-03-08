// react
import React from 'react';

import { useSelector } from 'react-redux';

// react-bootstrap
import Tab from 'react-bootstrap/Tab';
import Tabs from 'react-bootstrap/Tabs';

const TotalStock = () => {

    const users = useSelector(state => state.sys.users && state.sys.users.data);

    if(!users) return;
    
    return (
        <div >
           
            총재고관리...
            <div>UsrMgmts ==> LENGTH: {users.data.length}  </div>
        </div>
    )
};
export default TotalStock;