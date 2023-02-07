// react
import React from 'react';

// react-bootstrap
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown';

const Header = () => {
    return (
        <Navbar collapseOnSelect  fixed="top" expand="md"  style={{backgroundColor: "#0747A6"}}>
            <Container >
                <Navbar.Brand href="/" style={{color:'white'}}>Logo</Navbar.Brand>
                <Navbar.Toggle aria-controls="responsive-navbar-nav" />
                <Navbar.Collapse id="responsive-navbar-nav"  >
                    <Nav className="me-auto">
                        <Nav.Link href="/notice" style={{color:'white'}}>재고관리</Nav.Link>
                        <Nav.Link href="/profile" style={{color:'white'}} >재작준비</Nav.Link>
                        <Nav.Link href="/profile" style={{color:'white'}} >발간현황</Nav.Link>
                        <Nav.Link href="/profile" style={{color:'white'}} >운영관리</Nav.Link>
                        <Nav.Link href="/profile" style={{color:'white'}} >시스템관리</Nav.Link>
                        
                        <NavDropdown title={<span className="text-white my-auto">시스템관리</span>}>
                            <NavDropdown.Item href="#action/3.1">Action</NavDropdown.Item>
                            <NavDropdown.Item href="#action/3.2">
                                Another action
                            </NavDropdown.Item>
                            <NavDropdown.Item href="#action/3.3">Something</NavDropdown.Item>
                            <NavDropdown.Divider />
                            <NavDropdown.Item href="#action/3.4">
                                Separated link
                            </NavDropdown.Item>
                        </NavDropdown>

                    </Nav>
                    <Nav>
                        <Nav.Link href="/deets" >
                            <span style={{color:'white', fontSize: '12px'}}>현대자동차
                            <strong className='ms-1'>홍길동님</strong></span>
                        </Nav.Link>
                        <Nav.Link href="/deets">
                            <span style={{color:'white', fontSize: '12px'}}>로그아웃</span>
                        </Nav.Link>
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
};
export default Header;