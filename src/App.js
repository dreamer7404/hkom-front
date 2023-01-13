// react
import React from 'react';
import { BrowserRouter } from 'react-router-dom';

// components
import BaseRoutes from './components/Layout/BaseRoutes';

const App = () => {
  return (
    <BrowserRouter >
      <BaseRoutes />
    </BrowserRouter>
  );
};
export default App;
