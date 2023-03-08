/* eslint-disable react/prop-types */

import * as React from 'react';
import { useDEXT5Upload } from 'dext5upload-react';

const { useEffect, useState } = React;

/**
 * Custom `DEXT5Upload` component built on top of `useDEXT5Upload` hook.
 */
function DEXT5Upload( { config, debug, mode, componentUrl, id } ) {
	const [ element, setElement ] = useState();

	/**
	 * Sets initial value of `mode`.
	 */
	if ( config && mode ) {
		config.Mode = mode;
	}

	const { component, status } = useDEXT5Upload( {
		debug,
		element,
		config,
		componentUrl
	} );

	/**
	 * Toggles `mode` on runtime.
	 */
	useEffect( () => {
		if ( component && status === 'ready' ) {
			( DEXT5UPLOAD.IsLoadedUploadEx(component.object.ID) ) && ( DEXT5UPLOAD.SetUploadMode(mode, component.object.ID) );
		}
	}, [ component, mode ] );

	return (
		<div
			id={id}
			ref={setElement}
		></div>
	);
}

export default DEXT5Upload;
