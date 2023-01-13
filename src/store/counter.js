// action type
const SET_DIFF = 'SET_DIFF';
const INCREASE = 'INCREASE';
const DECREASE = 'DECREASE';

// action function
export const setDiff = diff => ({type: SET_DIFF, diff});
export const increase = () => ({type: INCREASE});
export const decrease = () => ({type: DECREASE});

// initialize
const initialState = {
    number: 0,
    diff: 1
};

// reducer
export default function counter(state = initialState, action){
    switch(action.type){
        case SET_DIFF: return {...state, diff: action.diff};
        case INCREASE: return {...state, number: state.number + state.diff};
        case DECREASE: return {...state, number: state.number - state.diff};
        default: return state;
    }
}