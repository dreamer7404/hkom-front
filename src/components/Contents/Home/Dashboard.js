// react
import React from 'react';
import CounterContainer from '../Test/CounterContainer';
import PostListContainer from '../Test/PostContainer';
import { DEXT5Editor } from 'dext5editor-react';

const Dashboard = () => {

     //기술문의: 02-584-3927 정기평
	const aaa = () => {
		// eslint-disable-next-line no-undef
		console.log(DEXT5.getBodyValue());
		// eslint-disable-next-line no-undef
		// DEXT5.SetRealPath("C:\\Users\\H2212239\\git\\ioms_mybatis\\ioms_mybatis\\src\\main\\resources\\static\\uploadFiles");
		// DEXT5.SetRealPath("c:\\temp");
	}
	const bbb = () => {
		// eslint-disable-next-line no-undef
		DEXT5.setBodyValue('aaaaaaaaaaaaaaaaa');
	}

    return (
        <div >
            Dashboard...
            <div>
                <PostListContainer />
            </div>

            <section>
				<DEXT5Editor
					debug={true}
					id="editor1"
					componentUrl="/dext5editor/js/dext5editor.js"
					config={{ DevelopLangage:'NONE' }}
					initData="<p>Hello <strong>DEXT5 Editor</strong> world!</p>"
				/>
			</section>
            <div><button className='btn btn-primary' onClick={aaa}>get html</button></div>
			<div><button className='btn btn-primary' onClick={bbb}>set html</button></div>
           
        </div>
    )
};
export default Dashboard;