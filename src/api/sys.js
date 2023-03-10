
import axios from 'axios';

export const getUsrmgmtList = async (param) => {
    return await axios.get(`http://localhost:8000/api/usrmgmts?pageNo=${param.pageNo}&pageSize=${param.pageSize}&orderBy=${param.orderBy}`);
}

export const insertUsrmgmt = async (param) => {
    return await axios.post(`http://localhost:8000/api/usrmgmt`, {});
}
export const getPgmmgmtList = async (param) => {
    return await axios.get(`http://localhost:8000/api/pgmMgmts`);
}
