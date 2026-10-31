import { lazy } from 'react';
import { ROUTES } from '@constants/routes';
import { createBrowserRouter, Navigate } from 'react-router-dom';
import authService from '@services/auth.service';
import App from '@/App';
import ErrorBoundary from '@/shared/Layouts/ErrorBoundary';
import Login from '@/modules/Auth/Login';
import ErrorComponent from '@/shared/Layouts/ErrorComponent';

const PromoCodeList = lazy(() => import('@/modules/PromoCode/PromoCodeList'));
const SegmentsList = lazy(() => import('@/modules/Segments/SegmentsList'));
const WashingServices = lazy(() => import('@/modules/WashingServices/WashingServices'));
const WashingServicesDetails = lazy(() => import('@/modules/WashingServices/_view/WashingServicesDetails'));
const SegmentDetails = lazy(() => import('@/modules/Segments/_view/SegmentDetails'));
const BikersList = lazy(() => import('@/modules/Bikers/BikersList'));
const BikersDetails = lazy(() => import('@/modules/Bikers/_view/BikersDetails'));
const BikersSchedule = lazy(() => import('@/modules/Bikers/_view/BikersSchedule'));
const OrdersList = lazy(() => import('@/modules/orders/OrdersList'));
const Pointes = lazy(() => import('@/modules/Pointes/Pointes'));
const Plans = lazy(() => import('@/modules/Plans/Plans'));
const PlansDetails = lazy(() => import('@/modules/Plans/_view/PlansDetails'));
const AddOnsList = lazy(() => import('@/modules/AddOns/AddOnsList'));
const AddOnsDetails = lazy(() => import('@/modules/AddOns/_view/AddOnsDetails'));
const AdminsList = lazy(() => import('@/modules/Admins/AdminsList'));
const AdminDetails = lazy(() => import('@/modules/Admins/AdminDetails'));
const OrderDetails = lazy(() => import('@/modules/orders/_view/OrderDetails'));
const AssignOrderList = lazy(() => import('@/modules/AssignOrders/AssignOrderList'));
const NotificationList = lazy(() => import('@/modules/Notification/NotificationList'));
const TrancactionsList = lazy(() => import('@/modules/Transaction/TrancactionsList'));
const Dashboard = lazy(() => import('@/modules/Dashboard/Dashboard'));
const UsersList = lazy(() => import('@/modules/Users/UsersList'));
const Icons = lazy(() => import('@/modules/Icons/Icons'));
const UsersDetails = lazy(() => import('@/modules/Users/_view/UsersDetails'));
const Terms = lazy(() => import('@/modules/terms-conditions/Terms'));
const BannerList = lazy(() => import('@/modules/Banner/BannerList'));
const ContactInfo = lazy(() => import('@/modules/ContactInfo/ContactInfo'));
const Profile = lazy(() => import('@/modules/Profile/Profile'));
const Booking = lazy(() => import('@/modules/booking/Booking'));
const BookingCalendarV = lazy(() => import('@/modules/booking-calendar/BookingCalendar'));

type TLoginLoader = Promise<{
  isLoggedIn: boolean;
}>;

const router = createBrowserRouter([
  {
    path: ROUTES.MAIN,
    element: <App />,
    loader: async (): TLoginLoader => ({ isLoggedIn: await authService.isLoggedIn() }),
    errorElement: <ErrorBoundary isRoot />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: ROUTES.DASH_BOARD, element: <Dashboard /> },

      { path: ROUTES.ADMIN, element: <AdminsList /> },
      { path: ROUTES.ADMIN_DETAILS, element: <AdminDetails /> },

      { path: ROUTES.USERS, element: <UsersList /> },
      { path: ROUTES.USERS_DETAILS, element: <UsersDetails /> },

      { path: ROUTES.BIKERS, element: <BikersList /> },
      { path: ROUTES.BIKERS_DETAILS, element: <BikersDetails /> },
      { path: ROUTES.BIKERS_SCHEDULE, element: <BikersSchedule /> },

      { path: ROUTES.WASHING_SERVICES, element: <WashingServices /> },
      { path: ROUTES.WASHING_SERVICES_DETAILS, element: <WashingServicesDetails /> },

      { path: ROUTES.PLANS, element: <Plans /> },
      { path: ROUTES.PLANS_DETAILS, element: <PlansDetails /> },

      { path: ROUTES.ADD_ONS, element: <AddOnsList /> },
      { path: ROUTES.ADD_ONS_DETAILS, element: <AddOnsDetails /> },

      { path: ROUTES.PROMO_CODE, element: <PromoCodeList /> },

      { path: ROUTES.SEGMENTS, element: <SegmentsList /> },
      { path: ROUTES.SEGMENTS_DETAILS, element: <SegmentDetails /> },

      { path: ROUTES.ORDER, element: <OrdersList /> },
      { path: ROUTES.ORDER_DETAILS, element: <OrderDetails /> },
      { path: ROUTES.ASSIGN_ORDER, element: <AssignOrderList /> },

      { path: ROUTES.POINTES, element: <Pointes /> },

      { path: ROUTES.ICONS, element: <Icons /> },
      { path: ROUTES.TERMS_AND_CONDITIONS, element: <Terms /> },
      { path: ROUTES.APP_BANNER, element: <BannerList /> },
      { path: ROUTES.CONTACT_INFO, element: <ContactInfo /> },
      { path: ROUTES.BOOKING, element: <Booking /> },
      { path: ROUTES.BOOKING_CALENDAR, element: <Navigate to={ROUTES.BOOKING_CALENDAR_2} replace /> },
      { path: ROUTES.BOOKING_CALENDAR_2, element: <BookingCalendarV /> },
      { path: ROUTES.PROFILE, element: <Profile /> },

      { path: ROUTES.NOTIFICATION, element: <NotificationList /> },
      { path: ROUTES.TRANSCTION, element: <TrancactionsList /> },
    ],
  },
  {
    path: ROUTES.LOG_IN,
    element: <Login />,
  },
]);

export default router;
