import React from 'react';
import { DEXT5Upload } from 'dext5upload-react';
import { HashRouter, NavLink, Route, Routes } from 'react-router-dom';

function App() {
	return (
		<HashRouter>
			<div>
				<Routes>
					<Route path="/" element={<h1>{'Home page'}</h1>} />
					<Route path="/component" element={<DEXT5Upload
						debug={true}
						id='dext5upload1'
						
						mode='edit'
						config={{MaxTotalFileSize:'100MB', MaxOneFileSize:'10MB', DevelopLangage:'NONE'}}
						componentUrl="/dext5upload/js/dext5upload.js"
					/>} />
				</Routes>
				<div>
					<div>
						<NavLink to="/">{'Home page'}</NavLink>
					</div>
					<div>
						<NavLink to="/component">{'Component page'}</NavLink>
					</div>
				</div>
				<footer>{`Running React v${ React.version }`}</footer>
			</div>
		</HashRouter>
	);
}

export default App;
