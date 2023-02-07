// react
import React from 'react';
import { Suspense } from 'react';
import { BrowserRouter } from 'react-router-dom';

// components
import BaseRoutes from './components/Layout/BaseRoutes';

const App = () => {
  return (
    <BrowserRouter >
      {/* <Suspense  fallback={<div>loading.....</div>}> */}
        <BaseRoutes />
      {/* </Suspense> */}
    </BrowserRouter>
  );
};
export default App;
