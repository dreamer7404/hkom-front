// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';

// components
import Header from "./Header";
import Header2 from "./Header2";
import Footer from "./Footer";
import Section from './Section';

// style
import '../../styles/layer.css';
import SitePath from './SitePath';

const BaseLayout = ({children}) => {
    
    return (
        <Container fluid>
            <Header2  />
            <div className='mb-5'>&nbsp;</div>
            {/* <SitePath  /> */}
            <Section children={children} />
            <Footer />
        </Container>
    );
};
export default BaseLayout;