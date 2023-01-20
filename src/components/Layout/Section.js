// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';

const Section = ({children}) => {
    return(
        <Container fluid>
            {/* <div className='wrapper'> */}
                {children}
            {/* </div> */}
        </Container>
    );
};
export default Section;
