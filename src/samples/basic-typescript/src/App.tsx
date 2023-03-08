import * as React from 'react';
import { DEXT5Upload } from 'dext5upload-react';

function App() {
	return (
		<div>
			<section>
				<DEXT5Upload 
					debug={true}
					id="dext5upload1"
					
					mode='edit'
					
					componentUrl="/dext5upload/js/dext5upload.js"
					config={{MaxTotalFileSize:'100MB', MaxOneFileSize:'10MB', DevelopLangage:'NONE'}}
				/>
			</section>
			<footer>{`Running React v${ React.version }`}</footer>
		</div>
	);
}

export default App;
