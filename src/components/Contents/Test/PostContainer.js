import React from 'react';
import { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';

import { getPost } from '../../../store/posts';
import Post from './Post';

function PostContainer({ match }) {

    const { id } = useParams();

    const {data, loading, error} = useSelector(state => state.posts.post);
    const dispatch = useDispatch();

    useEffect(() => {
        dispatch(getPost(parseInt(id, 10)));
    }, [id, dispatch]);

    if (loading) return <div>로딩중...</div>;
    if (error) return <div>에러 발생!</div>;
    if (!data) return null;

    return (
        <div>
            {/* <Post post={data} /> */}
            <h1>{data.title}</h1>
            <p>{data.body}</p>
       </div>
    );
};
export default PostContainer;