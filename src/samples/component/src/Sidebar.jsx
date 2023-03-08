/* eslint-disable react/prop-types */

import * as React from 'react';

function Sidebar( {	
	runtimes,
	mode,
	onRuntimesChange,
	onModeChange
} ) {
	return (
		<aside className="paper flex-grow-1">
			<div className="option">
				<div>{'Mode:'}</div>
				{[ 'edit', 'view' ].map( modeDef => (
					<div key={modeDef}>
						<input
							id={modeDef}
							type="radio"
							name={modeDef}
							checked={modeDef === mode}
							value={modeDef}
							onChange={onModeChange}
						/>
						<label htmlFor={modeDef}>{modeDef}</label>
					</div>
				) )}
			</div>
		</aside>
	);
}

export default Sidebar;
