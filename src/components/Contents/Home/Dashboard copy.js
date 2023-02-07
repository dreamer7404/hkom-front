// react
import React, {useEffect} from 'react';
import CounterContainer from '../Test/CounterContainer';
import PostListContainer from '../Test/PostListContainer';
import { DEXT5Editor } from 'dext5editor-react';

import { useQuery, useQueries } from 'react-query';

import axios from 'axios';


const Dashboard = () => {

     //기술문의: 02-584-3927 정기평
	const aaa = () => {
		// eslint-disable-next-line no-undef
		console.log(DEXT5.getBodyValue());
		// eslint-disable-next-line no-undef
		// DEXT5.SetRealPath("C:\\Users\\H2212239\\git\\ioms_mybatis\\ioms_mybatis\\src\\main\\resources\\static\\uploadFiles");
		// DEXT5.SetRealPath("c:\\temp");
	}
	const bbb = () => {
		// eslint-disable-next-line no-undef
		DEXT5.setBodyValue('aaaaaaaaaaaaaaaaa');
	}

    const sleep = n => new Promise(resolve => setTimeout(resolve, n));

    const fetchPostList = async () => {
        // await sleep(1000);
        return axios.get('https://jsonplaceholder.typicode.com/posts');
        
    };
    const fetchTodoList = async () => {
        return await axios.get('https://jsonplaceholder.typicode.com/todos');
    };

 //---------------- useQuery -------------------------------------------------
   
    // const { data: postList, error, isFetching } = useQuery(["posts"], fetchPostList, {
    //     // enabled: !!todoList,
    //     onSuccess: data => {
    //       console.log('postList', data);
    //     },
    // });
    // const {data: todoList, error2, isFetching2 } = useQuery(["todos"], fetchTodoList, {
    //     enabled: !!postList, // postList가 true이면 => postList가 로딩되면...
    //     onSuccess: data => {
    //       console.log('TodoList',data);
    //     },
    // });
  

     //---------------- simple useQuery -------------------------------------------------

   


    const postList = useQuery("posts", fetchPostList); 

    useEffect(() => {
        console.log(postList);
    },[postList] )


    if (postList.isLoading) {
        return <h1 ><strong>Loading...</strong></h1>;
    }
    if (postList.isError) {
        return <h1 ><strong>Error: {postList.error.message}</strong></h1>;
    }

    //---------------- useQueries -------------------------------------------------
    // const result = useQueries([
    //     {queryKey: ['posts'], queryFn: () => axios.get('https://jsonplaceholder.typicode.com/posts') },
    //     {queryKey: ['todos'], queryFn: () => axios.get('https://jsonplaceholder.typicode.com/todos') }
    // ]);

    // useEffect(() => {
    //      const loadingFinishAll = result.some(result => result.isLoading);
    //     console.log(loadingFinishAll);
    //     console.log(result);
    // },[result] )
    
  
    return (
        <div >
            Dashboard...
            <div>
                <PostListContainer />
            </div>
            {/* <div>
                {postList.status}
            </div>
            <div>
                {postList.data.data.map(d => (
                    <li key={d.id}>{d.title}</li>
                ))}
            </div> */}

            <section>
				{/* <DEXT5Editor
					debug={true}
					id="editor1"
					componentUrl="/dext5editor/js/dext5editor.js"
					config={{ DevelopLangage:'NONE' }}
					initData="<p>Hello <strong>DEXT5 Editor</strong> world!</p>"
				/> */}
			</section>
            <div><button className='btn btn-primary' onClick={aaa}>get html</button></div>
			<div><button className='btn btn-primary' onClick={bbb}>set html</button></div>
           
        </div>
    )
};
export default Dashboard;