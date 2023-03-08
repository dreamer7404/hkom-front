import {Get, Post} from '../utils/utils';
import { getUsrmgmtList } from '../api/sys';
import { createPromiseThunk, reducerUtils, handleAsyncActions } from '../lib/asyncUtils';


const GET_USRMGMTS = 'GET_USRMGMTS'; 
const GET_USRMGMTS_SUCCESS = 'GET_USRMGMTS_SUCCESS'; 
const GET_USRMGMTS_ERROR = 'GET_USRMGMTS_ERROR'; 

const GET_USRMGMT = 'USRMGMT'; 
const GET_USRMGMT_SUCCESS = 'GET_USRMGMT_SUCCESS'; 
const GET_USRMGMT_ERROR = 'GET_USRMGMT_ERROR'; 


export const getUsrMgmts = createPromiseThunk(GET_USRMGMTS, getUsrmgmtList);
// export const getUsrMgmt = createPromiseThunk(GET_USRMGMT, Get('/usrmgmt'));

const initialState = {
    users: reducerUtils.initial(),
    user: reducerUtils.initial()
};

export default function posts(state = initialState, action) {
    switch (action.type) {
      case GET_USRMGMTS:
      case GET_USRMGMTS_SUCCESS:
      case GET_USRMGMTS_ERROR:
        return handleAsyncActions(GET_USRMGMTS, 'users')(state, action);
      case GET_USRMGMT:
      case GET_USRMGMT_SUCCESS:
      case GET_USRMGMT_ERROR:
        return handleAsyncActions(GET_USRMGMT, 'user')(state, action);
      default:
        return state;
    }
  }
