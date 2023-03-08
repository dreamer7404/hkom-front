/* eslint-disable react/prop-types */

import * as React from 'react';
import { DEXT5Upload } from 'dext5upload-react';
/**
 * `DEXT5Upload` component accepts handlers for all component events, e.g. `creationComplete` -> `onCreationComplete`.
 *
 * `DEXT5Upload` component ensures referential equality between renders for event handlers.
 * This means that first value of an event handler will be memoized and used through the lifecycle of `DEXT5Upload` component.
 */
function DEXT5UploadCmp( { pushEvent, uniqueName } ) {
	const handleBeforeLoad = () => {
		pushEvent( 'beforeLoad', '--' );
		console.log( {
			eventName: 'handleBeforeLoad',
			componentName: uniqueName
		});
	};

	const handleNamespaceLoaded = () => {
		pushEvent( 'namespaceLoaded', '--' );
		console.log( {
			eventName: 'handleNamespaceLoaded',
			componentName: uniqueName
		});
	};

	const handleLoaded = (eventParams) => {
		pushEvent( 'loaded', eventParams.eventInfo.componentName );
		console.log( {
			eventName: 'handleLoaded',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});
	};

	const handleCreationComplete = (eventParams) => {
		pushEvent( 'creationComplete', eventParams.eventInfo.componentName );
		console.log( {
			eventName: 'handleCreationComplete',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});
	};
	
	const handleBeforeAddItem = (eventParams) => {
		pushEvent( 'beforeAddItem', uniqueName );
		console.log( {
			eventName: 'handleBeforeAddItem',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});

		return true;
	};
	
	const handleAfterAddItem = (eventParams) => {
		pushEvent( 'afterAddItem', uniqueName );
		console.log( {
			eventName: 'handleAfterAddItem',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});
	};

	const handleAfterAddItemEndTime = (eventParams) => {
		pushEvent( 'afterAddItemEndTime', uniqueName );
		console.log( {
			eventName: 'handleAfterAddItemEndTime',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});
	};

	const handleTransferComplete = (eventParams) => {
		pushEvent( 'transferComplete', uniqueName );
		console.log( {
			eventName: 'handleTransferComplete',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});
	};

	const handleDestroy = (eventParams) => {
		pushEvent( 'destroy', uniqueName );
		console.log( {
			eventName: 'handleDestroy',
			componentName: eventParams.eventInfo.componentName,
			paramObj: eventParams.eventInfo.paramObj
		});
	};

	return (
		<DEXT5Upload
			debug={true}
			id={uniqueName}
			
			runtimes='html5'
			config={{MaxTotalFileSize:'100MB', MaxOneFileSize:'10MB', DevelopLangage:'NONE', HandlerUrl:'http://localhost:8314/handler/dext5handler.ashx'}}
			componentUrl="/dext5upload/js/dext5upload.js"

			onBeforeLoad={handleBeforeLoad}
			onNamespaceLoaded={handleNamespaceLoaded}
			onLoaded={handleLoaded}
			
			onCreationComplete={handleCreationComplete}

			onBeforeAddItem={handleBeforeAddItem}
			onAfterAddItem={handleAfterAddItem}
			onAfterAddItemEndTime={handleAfterAddItemEndTime}
			
			onTransferComplete={handleTransferComplete}

 			onDestroy={handleDestroy}
		/>
	);
}

export default DEXT5UploadCmp;
