// action type
const SET_DIFF = 'SET_DIFF';
const INCREASE = 'INCREASE';
const DECREASE = 'DECREASE';

// 액션함수
export const setDiff = diff => ({type: SET_DIFF, diff});
export const increase = () => ({type: INCREASE});
export const decrease = () => ({type: DECREASE});

// 비동기 액션함수 - 미들웨어
export const increaseAsync = () => dispatch => {
    setTimeout(() => dispatch(increase()), 1000);
};
export const decreaseAsync = () => dispatch => {
    setTimeout(() => dispatch(decrease()), 1000);
};

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