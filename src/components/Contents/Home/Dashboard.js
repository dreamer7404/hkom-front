// react
import React, {useEffect} from 'react';
import CounterContainer from '../Test/CounterContainer';
import PostListContainer from '../Test/PostListContainer';
import { DEXT5Editor } from 'dext5editor-react';

import { useQuery, useMutation, useQueryClient } from 'react-query';

import axios from 'axios';


const Dashboard = () => {



    const sleep = n => new Promise(resolve => setTimeout(resolve, n));

    const fetchPostList = async () => {
        console.log('11111')
        // await sleep(1000);
        return await axios.get('http://localhost:8000/usrMgmt/selectItemList');
        
    };
    const insertUser = async (user) => {
        return await axios.post('http://localhost:8000/usrMgmt/insertItem', user);
    };


    const postList = useQuery("posts", fetchPostList); 


    const queryClient = useQueryClient();
    const addUser = useMutation(insertUser, {
        onSuccess: () => {
            // queryClient.invalidateQueries("posts");

        }
    });


    const createUser = () => {
        addUser.mutate({userEeno: 'aaaa', userPw: 'bbbb', userNm: 'ahnks'});
        // insertUser({userEeno: 'aaaa', userPw: 'bbbb', userNm: 'ahnks'});
    };
    
  
    return (
        <div >
            Dashboard...
            <div>
                <PostListContainer />
            </div>
            <div>
                {postList.status}
            </div>
            <div>
                {postList.data.data.map(d => (
                    <li key={d.id}>{d.userNm}</li>
                ))}
            </div>

           
            <div><button className='btn btn-primary' onClick={createUser}>create user</button></div>
           
        </div>
    )
};
export default Dashboard;