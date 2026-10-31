import { ROUTES } from '@constants/routes';
import { createBrowserRouter } from 'react-router-dom';
import authService from '@services/auth.service';
import App from '@/App';
import ErrorBoundary from '@/shared/Layouts/ErrorBoundary';
import Login from '@/modules/Auth/Login';
import ErrorComponent from '@/shared/Layouts/ErrorComponent';
import PromoCodeList from '@/modules/PromoCode/PromoCodeList';
import SegmentsList from '@/modules/Segments/SegmentsList';
import WashingServices from '@/modules/WashingServices/WashingServices';
import WashingServicesDetails from '@/modules/WashingServices/_view/WashingServicesDetails';
import SegmentDetails from '@/modules/Segments/_view/SegmentDetails';
import BikersList from '@/modules/Bikers/BikersList';
import BikersDetails from '@/modules/Bikers/_view/BikersDetails';
import BikersSchedule from '@/modules/Bikers/_view/BikersSchedule';
import OrdersList from '@/modules/orders/OrdersList';
import Pointes from '@/modules/Pointes/Pointes';
import Plans from '@/modules/Plans/Plans';
import PlansDetails from '@/modules/Plans/_view/PlansDetails';
import AddOnsList from '@/modules/AddOns/AddOnsList';
import AddOnsDetails from '@/modules/AddOns/_view/AddOnsDetails';
import AdminsList from '@/modules/Admins/AdminsList';
import AdminDetails from '@/modules/Admins/AdminDetails';
import OrderDetails from '@/modules/orders/_view/OrderDetails';
import AssignOrderList from '@/modules/AssignOrders/AssignOrderList';
import NotificationList from '@/modules/Notification/NotificationList';
import TrancactionsList from '@/modules/Transaction/TrancactionsList';
import Dashboard from '@/modules/Dashboard/Dashboard';
import UsersList from '@/modules/Users/UsersList';
import Icons from '@/modules/Icons/Icons';
import UsersDetails from '@/modules/Users/_view/UsersDetails';
import Terms from '@/modules/terms-conditions/Terms';
import BannerList from '@/modules/Banner/BannerList';
import ContactInfo from '@/modules/ContactInfo/ContactInfo';
import Profile from '@/modules/Profile/Profile';
import Booking from '@/modules/booking/Booking';
import BookingCalendarV2 from '@/modules/booking-calendar/BookingCalendarV2';
import BookingCalendarV from '@/modules/booking-calendar/BookingCalendar';

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
      { path: ROUTES.BOOKING_CALENDAR, element: <BookingCalendarV2 /> },
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
