// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

const Header = () => {
    return (
        <Navbar collapseOnSelect  fixed="top" expand="lg" bg="primary" >
            <Container >
                <Navbar.Brand href="/">Logo</Navbar.Brand>
                <Navbar.Toggle aria-controls="responsive-navbar-nav" />
                <Navbar.Collapse id="responsive-navbar-nav">
                    <Nav className="me-auto">
                        <Nav.Link href="/notice">공지사항</Nav.Link>
                        <Nav.Link href="/profile">내정보</Nav.Link>
                    </Nav>
                    <Nav>
                        <Nav.Link href="/deets">로그아웃</Nav.Link>
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
};
export default Header;