import * as React from 'react';
import Sidebar from './Sidebar';
import DEXT5Upload from './DEXT5Upload';

const { version, useRef, useState } = React;

function App() {
	const [ events, setEvents ] = useState( [] );
	const [ uniqueName, setUniqueName ] = useState( getUniqueName() );
	const start = useRef( new Date() );

	const handleRemountClick = () => {
		setUniqueName( getUniqueName() );
	};

	const pushEvent = ( evtName, componentName ) => {
		setEvents( events =>
			events.concat( {
				evtName,
				componentName: componentName,
				date: new Date()
			} )
		);
	};

	return (
		<div>
			<section className="container">
				<Sidebar events={events} start={start.current} />
				<div className="paper flex-grow-3">
					<DEXT5Upload
						key={uniqueName}
						pushEvent={pushEvent}
						uniqueName={uniqueName}
					/>
					<button className="btn" onClick={handleRemountClick}>
						{'Re-mount component'}
					</button>
				</div>
			</section>
			<footer>{`Running React v${ version }`}</footer>
		</div>
	);
}

function getUniqueName() {
	return Math.random()
		.toString( 36 )
		.replace( /[^a-z]+/g, '' )
		.substr( 0, 5 );
}

export default App;
