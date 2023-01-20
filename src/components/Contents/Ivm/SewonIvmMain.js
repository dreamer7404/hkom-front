// react
import React from 'react';

// react-bootstrap
import {Tab,Tabs} from 'react-bootstrap';

// component
import SewonIvm from './SewonIvm/SewonIvm';

const SewonIvmMain = () => {

    return (
        <div >
             <Tabs  defaultActiveKey="tab1">
                <Tab eventKey="tab1" title={<strong>세원재고관리</strong>}>
                    <SewonIvm />
                </Tab>
                <Tab eventKey="tab2" title="출고현황">
                    출고현황
                </Tab>
                <Tab eventKey="tab3" title="재고보정">
                재고보정
                </Tab>
                <Tab eventKey="tab4" title="차종재고분석">
                차종재고분석
                </Tab>
                <Tab eventKey="tab5" title="요청현황">
                요청현황
                </Tab>
            </Tabs>
        </div>
    )
};
export default SewonIvmMain;