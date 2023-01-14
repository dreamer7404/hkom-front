// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';

// components
import Header2 from "./Header2";
import Footer from "./Footer";
import Section from './Section';

// style
import '../../styles/layer.css';

const BaseLayout = ({children}) => {
    return (
        <Container fluid>
            <Header2 />
            <Section children={children} />
            <Footer />
        </Container>
    );
};
export default BaseLayout;