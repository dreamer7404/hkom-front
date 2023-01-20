// react
import React, {useState} from 'react';



// react-bootstrap
import {Form, Row, Col, Container} from 'react-bootstrap';


// rsute
import { CustomProvider , Button, DatePicker, SelectPicker, Panel, Divider } from 'rsuite';
import 'rsuite/dist/rsuite.min.css'; // or 'rsuite/dist/rsuite.min.css'
import ko from 'rsuite/locales/ko_KR';


const SewonIvm = () => {

    const data = ['전체', '울산', '아산'].map(
        item => ({ label: item, value: item })
      );
      

    return (
        <Container fluid className='mt-3'>
            {/* <div>세원재고관리..<Button appearance="primary">Hello World</Button>;</div> */}
            <div>
                {/* <div className='row border'>
                    <div className='col'>기준일</div>
                    <div className='col'>
                        <CustomProvider locale={ko}>
                            <DatePicker oneTap defaultValue={new Date()} />
                        </CustomProvider>
                    </div>
                    <div className='col'>기준일</div>
                    <div className='col'>
                        <CustomProvider locale={ko}>
                            <DatePicker oneTap  defaultValue={new Date()} />
                        </CustomProvider>
                    </div>
                </div> */}

                <Panel bordered style={{background: '#efefef'}}>
                <form>
                    {/* <div className="row mb-3 border noPadding"> */}
                    <Row>
                        <Col sm={2} className="pe-1">
                            <Form.Group>
                                <Form.Label column="sm">기준일</Form.Label>
                                <Col>
                                    <CustomProvider locale={ko}>
                                        <DatePicker oneTap block size="sm" defaultValue={new Date()} />
                                    </CustomProvider>
                                </Col>
                            </Form.Group>
                        </Col>
                        
                        <Col sm={1} className="pe-0" >
                            <Form.Group >
                                <Form.Label column="sm">지역</Form.Label>
                                {/* <Form.Select size="sm">
                                    <option value="">전체</option>
                                    <option value="1">울산</option>
                                    <option value="2">아산</option>
                                    <option value="3">Three</option>
                                </Form.Select>  */}
                                <SelectPicker value={'울산'} size="sm" data={data} style={{ width: 224 }} />
                            </Form.Group>
                        </Col>
                        <Col sm={2} className="px-0" >
                            <Form.Group>
                                <Form.Label column="sm" >차종</Form.Label>
                                <Form.Select size="sm">
                                    <option value="">전체</option>
                                    <option value="1">AA(AA-CAR)</option>
                                    <option value="2">AD(AVANTE)</option>
                                </Form.Select> 
                            </Form.Group>
                        </Col>
                        <Col sm={1} className="ps-0">
                            <Form.Group as={Col}>
                                <Form.Label column="sm" >MY</Form.Label>
                                <Form.Control type="text" size="sm" />
                            </Form.Group>
                        </Col>
                        <Col sm={1} className="pe-0" >
                            <Form.Group>
                                <Form.Label column="sm" >언어지역</Form.Label>
                                <Form.Select size="sm">
                                    <option value="">전체</option>
                                    <option value="1">북미</option>
                                    <option value="2">유럽</option>
                                </Form.Select> 
                            </Form.Group>
                        </Col>
                        <Col sm={2} className="ps-0" >
                            <Form.Group>
                                <Form.Label column="sm" >언어</Form.Label>
                                <Form.Select size="sm">
                                    <option value="">전체</option>
                                    <option value="1">AR(영어,아랍어/중동)</option>
                                    <option value="2">AS(영어,아랍어/시리아)</option>
                                </Form.Select> 
                            </Form.Group>
                        </Col>
                        <Col sm={1} className="px-1" >
                            <Form.Group>
                                <Form.Label column="sm" >배송여부</Form.Label>
                                <Form.Select size="sm">
                                    <option value="">전체</option>
                                    <option value="1">배송중</option>
                                    <option value="2">배송완료</option>
                                </Form.Select> 
                            </Form.Group>
                        </Col>
                        <Col sm={1} className="px-1" >
                            <Form.Group>
                                <Form.Label column="sm" >재고대상</Form.Label>
                                <Form.Select size="sm">
                                    <option value="">전체</option>
                                    <option value="1">OK</option>
                                    <option value="2">준비</option>
                                </Form.Select> 
                            </Form.Group>
                        </Col>
                        <Col sm={1}>
                            <Form.Group>
                                <Form.Label column="sm" >&nbsp;</Form.Label>
                                <Col>
                                    <Button appearance="primary" size="sm">조회</Button>
                                </Col>
                            </Form.Group>
                        </Col>
                    </Row>
                </form>
                </Panel>
            </div>
            
           
        </Container>
    )
};
export default SewonIvm;