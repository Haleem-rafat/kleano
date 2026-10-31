import segmentsService from '@services/segments.service';
import useSWR from 'swr';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

const ViewUsers = ({ segmentId }: { segmentId: string }) => {
  const fetchUsers = async (segmentId) => {
    return await segmentsService.getSegmentUsers(segmentId).then((data) => {
      return data;
    });
  };
  const { data: usersData } = useSWR(['/api/segment-data', segmentId], () => fetchUsers(segmentId));
  return (
    <div className="h-[30rem] w-[34rem]  p-2">
      <Table>
        <TableHeader>
          <TableRow>
            {['Name', 'Email'].map((item, index) => (
              <TableHead key={index} className="">
                {item}
              </TableHead>
            ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {usersData &&
            usersData?.data?.users?.map((user) => (
              <TableRow className="" key={user._id}>
                <TableCell>{user.userName}</TableCell>
                <TableCell>{user.email}</TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
    </div>
  );
};

export default ViewUsers;
