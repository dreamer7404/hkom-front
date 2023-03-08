// react
import React, {useEffect, useState, useCallback} from 'react';
import CounterContainer from '../Test/CounterContainer';
import PostListContainer from '../Test/PostListContainer';
import { DEXT5Editor } from 'dext5editor-react';

import { useQuery, useMutation, useQueryClient } from 'react-query';


import { Button} from 'rsuite';


import UsrMgmts from '../Sys/UsrMgmts';

import { Link } from 'react-router-dom';
import { insertUsrmgmt, getUsrmgmtList } from '../../../api/sys';



const Dashboard = () => {

    const sleep = n => new Promise(resolve => setTimeout(resolve, n));

    const insertUser = async (user) => {
        // return await axios.post('http://localhost:8000/usrMgmt/insertItem', {'_method': 'insert'}, user);
    };


    // const param = {pageNo: 1, pageSize: 2, orderBy: 'userNm ASC'};
    // const postList = useQuery(['posts', param], () => usrmgmts(param)); 


    const queryClient = useQueryClient();
   

    // const addUser = useMutation(insertUser, {
    //     onSuccess: () => {
    //         // queryClient.invalidateQueries("posts");

    //     }
    // });

// 
    const [param, setParam] = useState(null);
    // const [param, setParam] = useState({pageNo: 1, pageSize: 2, orderBy: 'userNm ASC'});
    // const param = {pageNo: 1, pageSize: 2, orderBy: 'userNm ASC'};
    // const {data, isSuccess, refetch} = useQuery(['posts', param], () => usrmgmts(param), {enabled: true}); 
    const {data, isSuccess, refetch} = useQuery(['posts', param], () => getUsrmgmtList(param), {enabled: false, staleTime: 5000,
        cacheTime: Infinity,}); 



    useEffect(() => {
        console.log(queryClient);

        if(param){
            console.log('############')
            refetch(param);
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [param]);

    const getUser = () => {
        setParam ({pageNo: 1, pageSize: 3, orderBy: 'userNm ASC'});
        // refetch({pageNo: 1, pageSize: 3, orderBy: 'userNm ASC'});

        // const newParam = {pageNo: 1, pageSize: 3, orderBy: 'userNm ASC'};
        // queryClient.setQueryData(['posts', newParam], () => usrmgmts(newParam));
    }
    const getUserBySetData = () => {
        const newParam = {pageNo: 1, pageSize: 3, orderBy: 'userNm ASC'};
        queryClient.setQueryData(['posts', newParam], () => getUsrmgmtList(newParam));
        // refetch();
    }

    const getQueryData = () => {
        const qData = queryClient.getQueryData(['posts', param]);
        console.log(qData);
    }
    const cancelQueries = () => {
        const qData = queryClient.cancelQueries(['posts', param]);
        console.log(qData);
    }



    



    const addUser = useMutation(insertUsrmgmt, {
            onSuccess: () => {
                // setUserId(userId + 1);
                console.log('### success mutation!!!!');
            },
    });
    const createUser = () => {
        // addUser.mutate({userEeno: 'aaaa', userPw: 'bbbb', userNm: 'ahnks'});
        // insertUser({userEeno: 'aaaa', userPw: 'bbbb', userNm: 'ahnks'});

        addUser.mutate({name: 'ahnks'});
    };

    

    
    // if(isSuccess) console.log(data);
    
    
    return (
        <div >
            Dashboard...
            <div>
                <Link to='/totalStock'>totalStock</Link>
            </div>
            <div>
                {/* <PostListContainer /> */}
            </div>
            <div>
                <UsrMgmts />
            </div>

            <div>
                LEN: {data && data.data.length} 
            </div>
            <div>
                {data && data.data.map((d, i) => (
                    <li key={i}>{d.userNm}</li>
                ))}
            </div>

            <div>
                <Link to="/testQuery">testQuery</Link>
            </div>


            <div className='m-1'>
                <Button appearance="primary" size="sm"  className='m-1' onClick={getUser}>get user</Button>
                <Button appearance="primary" size="sm"  className='m-1' onClick={getUserBySetData}>getUserBySetData</Button>
            </div>
            <div>
                <Button appearance="primary" size="sm"  className='m-1' onClick={cancelQueries}>cancelQueries</Button>
                <Button appearance="primary" size="sm"  className='m-1' onClick={getQueryData}>getQueryData</Button>
            </div>
            <div>
                <Button appearance="primary" size="sm"  className='m-1' onClick={createUser}>create user</Button>
            </div>

{isSuccess && 
            <DEXT5Editor
					debug={true}
					id="editor1"
					componentUrl="/dext5editor/js/dext5editor.js"
					config={{ DevelopLangage:'NONE' }}
					initData="<p>Hello <strong>DEXT5 Editor</strong> world!</p>"
				/>
                }
           
        </div>
    )
};
export default Dashboard;