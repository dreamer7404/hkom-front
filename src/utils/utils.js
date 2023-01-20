import axios from 'axios';

export const fetchData = async(url, params) => {
    const res =  await axios.post(url, params);
    return res.data;
}

  