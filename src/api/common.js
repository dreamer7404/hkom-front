import axios from 'axios';

export const usrmgmt = async (eeno) => {
    return await axios.get("http://localhost:8000/api/usrmgmt/" + eeno);
}