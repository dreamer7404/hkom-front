import data from './data';

export const getPosts = () => {
    return data.posts;
}

export const getPostById = id => {
    return  data.posts[2];
}