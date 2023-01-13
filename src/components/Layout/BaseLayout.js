// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';

// components
import Header from "./Header";
import Footer from "./Footer";
import Section from './Section';

// style
import '../../styles/layer.css';

const BaseLayout = ({children}) => {
    return (
        <Container fluid>

            <Header />

            <Section>
                {children}
            </Section> 

            <Footer />

        </Container>
    );
};
export default BaseLayout;