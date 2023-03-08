import { combineReducers } from "redux";
import counter from './counter';
import todos from './todos';
import posts from './posts';
import sys from './sys';

const rootReducer = combineReducers({
    counter,
    todos,
    posts,
    sys
});

export default rootReducer;