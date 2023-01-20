// react
import React from 'react';
import { Col, Button, Row, Container, Card, Form } from "react-bootstrap";
import { useForm } from "react-hook-form";

const Login = () => {

    const { register, handleSubmit } = useForm({ shouldUseNativeValidation: true });
    const onSubmit = async data => { 
        console.log(data); 
    };

    return (
        <Container>
            <form onSubmit={handleSubmit(onSubmit)}>
            <Row className="vh-100 d-flex justify-content-center align-items-center">
                <Col md={8} lg={6} xs={12}>
                    <div className="border border-3 border-primary"></div>
                    <Card className="shadow">
                    <Card.Body>
                        <div className="mb-3 mt-md-4">
                        <h2 className="fw-bold mb-2 text-uppercase ">오너스 매뉴얼 관리시스템</h2>
                        {/* <p className=" mb-5">Please enter your login and password!</p> */}
                        <div className="mb-3">
                            <Form.Group className="mb-3" controlId="formBasicEmail">
                                <Form.Label className="text-center">
                                아이디
                                </Form.Label>
                                <Form.Control type="text" placeholder="User ID" name="userId"
                                 {...register("userId", { required: '아이디를 입력해주세요' })} /> 
                               
                                
                            </Form.Group>

                            <Form.Group
                                className="mb-3"
                                controlId="formBasicPassword"
                            >
                                <Form.Label>패스워드</Form.Label>
                                <Form.Control type="password" placeholder="Password" name="password" 
                                 {...register("password", { required: '패스워드를 입력해주세요' })} />
                            </Form.Group>
                            <Form.Group
                                className="mb-3"
                                controlId="formBasicCheckbox"
                            >
                                <p className="small">
                                <a className="text-primary" href="#!">
                                    비밀번호찾기
                                </a>
                                </p>
                            </Form.Group>
                            <div className="d-grid">
                                <Button variant="primary" type="submit">
                                로그인
                                </Button>
                            </div>
                            {/* <div className="mt-3">
                            <p className="mb-0  text-center">
                                Don't have an account?{" "}
                                <a href="{''}" className="text-primary fw-bold">
                                Sign Up
                                </a>
                            </p>
                            </div> */}
                        </div>
                        </div>
                    </Card.Body>
                    </Card>
                </Col>
            </Row>
            </form>
        </Container>
    )
};
export default Login;