import * as React from 'react';
import {
	prefixEventName,
	stripPrefix,
	ComponentEventAction
} from 'dext5upload-react';
import Sidebar from './Sidebar';
import DEXT5Upload from './DEXT5Upload';

const { version, useReducer, useRef } = React;

function App() {
	const [ { events, uniqueName }, dispatch ] = useReducer( reducer, {
		events: [],
		uniqueName: getUniqueName()
	} );
	const start = useRef( new Date() );

	const handleRemountClick = () => {
		dispatch( { type: 'reMount', payload: getUniqueName() } );
	};

	return (
		<div>
			<section className="container">
				<Sidebar events={events} start={start.current} />
				<div className="paper flex-grow-3">
					<DEXT5Upload
						debug={true}
						key={uniqueName}
						id={uniqueName}
						mode='edit'
						config={{ MaxTotalFileSize:'100MB', MaxOneFileSize:'10MB', DevelopLangage:'NONE' }}
						componentUrl="/dext5upload/js/dext5upload.js"

						dispatchEvent={dispatch}
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

function reducer( state, action ) {
	switch ( action.type ) {
		case 'reMount':
			return {
				...state,
				uniqueName: action.payload
			};

		/**
		 * Event names are prefixed in order to facilitate integration with dispatch from `useReducer`.
		 * Access them via `ComponentEventAction`.
		 */
		case ComponentEventAction.namespaceLoaded:
		case ComponentEventAction.beforeLoad:
			return {
				...state,
				events: state.events.concat( {
					evtName: stripPrefix( action.type ),
					componentName: '--',
					date: new Date()
				} )
			};
		case ComponentEventAction.loaded:
		case ComponentEventAction.creationComplete:
		case ComponentEventAction.beforeAddItem:
		case ComponentEventAction.afterAddItem:
		case ComponentEventAction.transferComplete:
		case ComponentEventAction.destroy:
			return {
				...state,
				events: state.events.concat( {
					evtName: stripPrefix( action.type ),
					componentName: action.payload.eventInfo ? action.payload.eventInfo.componentName : "",
					date: new Date()
				} )
			};
		default:
			return state;
	}
}

function getUniqueName() {
	return Math.random()
		.toString( 36 )
		.replace( /[^a-z]+/g, '' )
		.substr( 0, 5 );
}

export default App;
