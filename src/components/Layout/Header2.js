// react
import React, {useState, useEffect} from 'react';
import { Route, Link } from 'react-router-dom';
import axios from 'axios';
import { useAsync } from 'react-async';


// bootstrap
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
import { faMinus, faCheckSquare , faSpinner, faHome, faChalkboardTeacher, faChevronRight} from '@fortawesome/free-solid-svg-icons'
import { faSquare } from "@fortawesome/free-regular-svg-icons";

import {fetchData} from '../../utils/utils';

// style
import '../../styles/styles.scss';

// local data
import {menuData}  from '../../data/menu';
import { getDropdownMenuPlacement } from 'react-bootstrap/esm/DropdownMenu';
import { assertExpressionStatement } from '@babel/types';


const Header2 = () => {

    const [show, setShow] = useState(false);
    const showDropdown = (e)=>{ 
        setShow(!show);
    }
    const hideDropdown = e => {
        setShow(false);
    }


    const [users, setUsers] = useState();
    useEffect(() => {
        // fetchData('http://localhost:8000/natlMgmt/selectItemList', {}).then(res => {
        //     setUsers(res);
        // });
    },[]);

    return (
        <div>
        <Navbar collapseOnSelect  fixed="top" expand="md"  style={{backgroundColor: "#0747A6"}}>
            <Container fluid className='ms-5' >
                <Navbar.Brand href="/" className='me-5' style={{color:'white'}}>Logo</Navbar.Brand>
                <Navbar.Toggle aria-controls="responsive-navbar-nav" />
                <Navbar.Collapse id="responsive-navbar-nav"  >
                    <Nav className="me-auto">
                        <NavDropdown
                            title={
                                <span>
                                {menuData.map((d, i) => (
                                    <span key={i} className={'me-4 ' + 'nav-no-selected'}>{d.title}</span>
                                ))}
                                </span>
                            }
                            id="basic-nav-dropdown"
                            // show={show}
                            // onMouseEnter={showDropdown} 
                            // onMouseLeave={hideDropdown}
                            // style={{background: 'red'}}
                            >
                            <Container className="eventsNav pt-0 mt-0" >
                                <div className='row'>
                                    {menuData.map((d, i) => (
                                        <div className="col text-left" key={d.cd} >
                                            <Dropdown.Header>{d.title}</Dropdown.Header>
                                            <Dropdown.Divider />
                                            {d.submenu.map((s, k) => (
                                                <Dropdown.Item key={s.cd} href={s.path}>{s.title}</Dropdown.Item>
                                            ))}
                                        </div>
                                    ))}
                                </div>
                            </Container>
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
            </Container >
        </Navbar>

        <div>
        {users && users.map((user,i) => (
          <li
            key={i}
            
            style={{ cursor: 'pointer' }}
          >
            {user.natNm} ({user.dlExpdNatCd})
          </li>
        ))}</div>  
       
        </div>
    );
};

export default Header2;