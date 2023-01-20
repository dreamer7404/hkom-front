// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';

// components
import Section from './Section';

const BasePage =({children}) => (
    <Container fluid>
        <Section children={children} />
    </Container>
);
export default BasePage;
