// react
import React, { Suspense, lazy } from 'react';
import {  Routes, Route, useLocation  } from 'react-router-dom';
import { TransitionGroup, CSSTransition } from 'react-transition-group';

// components
import BaseLayout from './BaseLayout';
import BasePage from './BasePage';
import PageLoader from '../Common/PageLoader';
import PostListContainer from '../Contents/Test/PostListContainer';
import PostContainer from '../Contents/Test/PostContainer';
import TestQuery from '../Contents/Test/TestQuery';

// children components
const Login = lazy(() => import('../Contents/Auth/Login'));
const Dashboard = lazy(() => import('../Contents/Home/Dashboard'));

const TotalStockMain = lazy(() => import('../Contents/Ivm/TotalStockMain'));
const SewonIvmMain = lazy(() => import('../Contents/Ivm/SewonIvmMain'));

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
                        <Route  path="/login" element={<Login />}></Route>
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
                                    <Route path="/postList" element={<PostListContainer />}></Route>
                                    <Route path="/post/:id" element={<PostContainer />}></Route>

                                    <Route path="/totalStock" element={<TotalStockMain />}></Route>
                                    <Route path="/sewonIvm" element={<SewonIvmMain />}></Route>
                                    <Route path="/" element={<Dashboard />}></Route>
                                     {/*<Route path="/profile" component={waitFor(Profile)} />
                                    <Route path="*" component={waitFor(Login)} /> */}


                                    <Route path="/testQuery" element={<TestQuery />}></Route>
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