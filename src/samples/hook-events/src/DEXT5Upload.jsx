/* eslint-disable react/prop-types */

import * as React from 'react';
import { useDEXT5Upload } from 'dext5upload-react';

const { useState } = React;

/**
 * Pass `dispatch` from `useReducer` in order to listen to component's events and derive state of your components as needed.
 */
function DEXT5UploadCmp( { config, debug, mode, componentUrl, id, dispatchEvent } ) {
	const [ element, setElement ] = useState();

	/**
	 * Sets initial value of `mode`.
	 */
	if ( config && mode ) {
		config.Mode = mode;
	}

	useDEXT5Upload( {
		debug,
		element,
		config,
		componentUrl,
		
		dispatchEvent,
		subscribeTo: [
			// Subscribed default events
			'namespaceLoaded',
			'beforeLoad',
			'loaded',
			'creationComplete',
			'beforeAddItem',
			'afterAddItem',
			'transferComplete',
			'destroy'
		]
	} );

	return <div id={id} ref={setElement} />;
}

export default DEXT5UploadCmp;
