import React from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { Button} from 'rsuite';

const TestQuery = () => {

    const queryClient = useQueryClient();

    const getData = () => {
        const newParam = {pageNo: 1, pageSize: 3, orderBy: 'userNm ASC'};
        // console.log(queryClient);

        // if (queryClient.isFetching()) {
            console.log(queryClient.getQueryCache().find(['posts', newParam]));
        // }

        
        const data = queryClient.getQueryData(['posts', newParam]);
        console.log(data);
    }

    return(
        <>
            <div>[TestQuery]</div>
            <div>
                <Button appearance="primary" size="sm"  className='m-1' onClick={getData}>getData</Button>
            </div>
        </>
    )

}
export default TestQuery;