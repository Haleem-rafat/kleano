import { ROUTES } from '@constants/routes';
import { useAppSelector } from '@hooks';
import { selectAuth } from '@store/slices/auth.slice';
import { Navigate, useLoaderData } from 'react-router-dom';

export const ProtectedRoute = ({ children }): React.ReactElement<React.ReactNode> => {
  const { isLoggedIn } = useLoaderData() as { isLoggedIn: boolean };
  const auth = useAppSelector(selectAuth);

  if (!isLoggedIn || !auth._id) return <Navigate to={ROUTES.LOG_IN} />;

  return children;
};
