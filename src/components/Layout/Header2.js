// react
import React, {useState} from 'react';
import { Route, Link } from 'react-router-dom';

// react-bootstrap
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Dropdown from 'react-bootstrap/Dropdown';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { fab } from '@fortawesome/free-brands-svg-icons'
import { faCoffee, faCheckSquare , faSpinner, faHome, faChalkboardTeacher, faChevronRight} from '@fortawesome/free-solid-svg-icons'
import { faSquare } from "@fortawesome/free-regular-svg-icons";

const Header2 = () => {

    const [show, setShow] = useState(false);
    const showDropdown = (e)=>{
        setShow(!show);
    }
    const hideDropdown = e => {
        setShow(false);
    }

    return (
        <div>

        <FontAwesomeIcon  icon={faSquare} size="2x" />
        <FontAwesomeIcon icon={faSpinner} />
        <FontAwesomeIcon icon={faHome} />
        <FontAwesomeIcon icon={faChevronRight} />


        <NavDropdown
            className="pr-2 py-2 align-text-top"
            title="Events"
            id="basic-nav-dropdown"
            show={show}
            onMouseEnter={showDropdown} 
            onMouseLeave={hideDropdown}
            >
            <Container className="eventsNav pt-0 mt-0">
                <Row>
                <Col xs="12" md="6" className="text-left">
                    <Dropdown.Header>
                    <FontAwesomeIcon
                        color="black"
                        icon={faCheckSquare}
                        size="1x"
                        className="pr-1"
                    />
                  
                    {"  "}
                    Catering
                    </Dropdown.Header>
                        <Dropdown.Item href="/">메뉴11</Dropdown.Item>
                        <Dropdown.Item>메뉴12</Dropdown.Item>
                        <Dropdown.Divider />
                        <Dropdown.Item>메뉴13</Dropdown.Item>
                    <Dropdown.Header>
                    {"  "}
                    Classes
                    </Dropdown.Header>
                    <Dropdown.Item href="/">Corporate</Dropdown.Item>
                        <Dropdown.Item>Private</Dropdown.Item>
                        <Dropdown.Divider />
                        <Dropdown.Item>Private111</Dropdown.Item>
                    <Dropdown.Divider className="d-md-none" />
                </Col>

                
                </Row>
            </Container>
        </NavDropdown>
        </div>
    );
};

export default Header2;