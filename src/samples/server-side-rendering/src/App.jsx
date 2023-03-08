import React from 'react';
import { DEXT5Upload } from 'dext5upload-react';

function App() {
	return (
		<div>
			<section>
				<DEXT5Upload 
					debug={true}
					id='kupload1'
					
					mode='edit'
					config={{MaxTotalFileSize:'100MB', MaxOneFileSize:'10MB', DevelopLangage:'NONE'}}
					
					componentUrl="/dext5upload/js/dext5upload.js"
				/>
			</section>
			<footer>{`Running React v${ React.version }`}</footer>
		</div>
	);
}

export default App;
