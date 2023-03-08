import * as React from 'react';
import { DEXT5Upload } from 'dext5upload-react';
import Sidebar from './Sidebar';

const { version, useReducer } = React;

/**
 * `App` component manages state of underlying `DEXT5Upload` and `Sidebar` components.
 *
 * `DEXT5Upload` component memoizes certain props and it will ignore any new values. For instance, this is true for `config` and `runtimes.
 * In order to force new `config` or `runtimes` values, use keyed component.
 * This way `DEXT5Upload` component is re-mounted and new instance of component is created.
 */
function App() {
	const [ { config, mode, runtimes, id }, dispatch ] =
		useReducer( reducer, {
			config: getConfig(),
			mode: 'edit',
			runtimes: 'html5',
			id: getUniqueName()
	} );

	const handleModeChange = evt => {
		const value = evt.currentTarget.value;
		dispatch( { type: 'mode', payload: value } );
	};

	return (
		<div>
			<section className="container">
				<Sidebar
					runtimes={runtimes}
					mode={mode}
					onModeChange={handleModeChange}
				/>
				<div className="paper flex-grow-3">
					<DEXT5Upload
						key={id}
						
						debug={true}
						id={id}
						mode={mode}
						config={config}
						componentUrl="/dext5upload/js/dext5upload.js"
					/>
				</div>
			</section>
			<footer>{`Running React v${ version }`}</footer>
		</div>
	);
}

function reducer( state, action ) {
	switch ( action.type ) {
		case 'mode':
			return {
				...state,
				mode: action.payload
			};
		default:
			return state;
	}
}

function getConfig( ) {
	return {
		...{ MaxTotalFileSize:'100MB', MaxOneFileSize:'10MB', DevelopLangage:'NONE' }
	};
}

function getUniqueName() {
	return Math.random()
		.toString( 36 )
		.replace( /[^a-z]+/g, '' )
		.substr( 0, 5 );
}

export default App;
