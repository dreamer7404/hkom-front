// react
import React, { Suspense, lazy } from 'react';
import {  Routes, Route, useLocation  } from 'react-router-dom';
import { TransitionGroup, CSSTransition } from 'react-transition-group';

// components
import BaseLayout from './BaseLayout';
import BasePage from './BasePage';
import PageLoader from '../Common/PageLoader';

// children components
const Login = lazy(() => import('../Contents/Auth/Login'));

const Notice = lazy(() => import('../Contents/Board/Notice'));
const Profile = lazy(() => import('../Contents/Profile/Profile'));


const waitFor = Tag => props => <Tag {...props}/>;

const noLayoutPages = [
    '/login',
    '/logout',
];

const BaseRoutes = () => {
    const location = useLocation();

    const currentKey = location.pathname.split('/')[1] || '/';
    const timeout = { enter: 500, exit: 500 };
    const animationName = 'rag-fadeIn'

    if(noLayoutPages.indexOf(location.pathname) > -1) {
        return (
            <BasePage>
                <Suspense fallback={<PageLoader />}>
                    <Routes location={location}>
                        <Route  path="/login" component={waitFor(Login)}/>
                        {/* <Route  path="/logout" component={waitFor(Logout)}/> */}
                    </Routes>
                </Suspense>
            </BasePage>
        );
    }else {
        return (
            <BaseLayout>
                 <TransitionGroup>
                    <CSSTransition key={currentKey} timeout={timeout} classNames={animationName} exit={false}>
                        <div>
                            <Suspense fallback={<PageLoader/>}>
                                <Routes location={location}>
                                    <Route path="/notice" element={<Notice />}></Route>
                                    <Route path="/profile" element={<Profile />}></Route>
                                     {/*<Route path="/profile" component={waitFor(Profile)} />
                                    <Route path="*" component={waitFor(Login)} /> */}
                                </Routes>
                             </Suspense>
                        </div>
                    </CSSTransition>
                </TransitionGroup> 
            </BaseLayout>
        );
    }

};
export default BaseRoutes;