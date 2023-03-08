import axios from 'axios';

export const Get = async(url) => {
    console.log('##############: ' + url)
    const res =  await axios.get('http://localhost:8000/api' + url);
    return res.data;
}

export const Post = async(url, params, method) => {
    const res =  await axios.post('http://localhost:8000/api' + url, params, {headers: {_method: method}});
    return res.data;
}

