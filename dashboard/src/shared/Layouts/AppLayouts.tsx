import { useEffect, useState } from 'react';
import { NavLink, useLoaderData, useNavigate } from 'react-router-dom';
import { GoSidebarCollapse } from 'react-icons/go';
import { AnimatePresence, motion } from 'framer-motion';
import { FiUser } from 'react-icons/fi';
import { FaBiking } from 'react-icons/fa';
import { RiCarWashingLine } from 'react-icons/ri';
import { BsBoxSeam, BsCardHeading } from 'react-icons/bs';
import { TbDiscount2, TbViewfinder } from 'react-icons/tb';
import { MdCardGiftcard } from 'react-icons/md';
import { PiLineSegments } from 'react-icons/pi';
import { BiNotification } from 'react-icons/bi';
import { LuLayoutDashboard } from 'react-icons/lu';
import { AiOutlineTransaction } from 'react-icons/ai';
import {
  Calendar,
  CalendarDays,
  FileText,
  Contact,
  Image,
  User,
  Palette,
  Shield,
  Star,
} from 'lucide-react';
import { getLocalStorageItem } from '@app/utils/local-storage';
import { ELocalStorageKeys } from '@constants/keys';
import { ROUTES } from '@constants/routes';
import { ILoginData } from '@servicesTypes/auth.types';
import { useTranslation } from 'react-i18next';

import classNames from 'classnames';
import { UserLoginDropDowen } from '@UI/Index';
import kleano_main_logo from '@assets/img/kleano-main-logo.png';
import { changeLangHandler } from '@app/utils/helper';
import i18n from '@app/locales/i18n';

import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shadecn/components/ui/select';

const navItems = [
  { icon: <LuLayoutDashboard size={20} />, label: 'dashboard', link: ROUTES.DASH_BOARD },
  { icon: <Shield size={20} />, label: 'admins', link: ROUTES.ADMIN },
  { icon: <FiUser size={20} />, label: 'users', link: ROUTES.USERS },
  { icon: <FaBiking size={20} />, label: 'bikers', link: ROUTES.BIKERS },
  {
    icon: <RiCarWashingLine size={20} />,
    label: 'washingServices',
    link: ROUTES.WASHING_SERVICES,
  },
  { icon: <BsCardHeading size={20} />, label: 'plans', link: ROUTES.PLANS },
  { icon: <MdCardGiftcard size={20} />, label: 'addOns', link: ROUTES.ADD_ONS },
  { icon: <TbDiscount2 size={20} />, label: 'promoCode', link: ROUTES.PROMO_CODE },
  { icon: <PiLineSegments size={20} />, label: 'segments', link: ROUTES.SEGMENTS },
  { icon: <BsBoxSeam size={20} />, label: 'orders', link: ROUTES.ORDER },
  // { icon: <TbViewfinder size={20} />, label: 'assignOrder', link: ROUTES.ASSIGN_ORDER },
  { icon: <Star size={20} />, label: 'pointes', link: ROUTES.POINTES },
  { icon: <Palette size={20} />, label: 'Icons', link: ROUTES.ICONS },
  { icon: <Calendar size={20} />, label: 'Booking', link: ROUTES.BOOKING },
  { icon: <CalendarDays size={20} />, label: 'Booking Calendar', link: ROUTES.BOOKING_CALENDAR_2 },
  {
    icon: <FileText size={20} />,
    label: 'Terms & Conditions',
    link: ROUTES.TERMS_AND_CONDITIONS,
  },
  {
    icon: <Contact size={20} />,
    label: 'Contact Info',
    link: ROUTES.CONTACT_INFO,
  },
  {
    icon: <Image size={20} />,
    label: 'App Banner',
    link: ROUTES.APP_BANNER,
  },
  {
    icon: <User size={20} />,
    label: 'Profile',
    link: ROUTES.PROFILE,
  },
  { icon: <BiNotification size={20} />, label: 'notification', link: ROUTES.NOTIFICATION },
  { icon: <AiOutlineTransaction size={20} />, label: 'transaction', link: ROUTES.TRANSCTION },
];

const navGroups: { title: string; labels: string[] }[] = [
  { title: 'Overview', labels: ['dashboard'] },
  { title: 'People', labels: ['users', 'bikers', 'admins'] },
  {
    title: 'Operations',
    labels: ['orders', 'Booking', 'Booking Calendar', 'transaction', 'notification'],
  },
  {
    title: 'Catalog',
    labels: ['washingServices', 'plans', 'addOns', 'promoCode', 'segments', 'pointes'],
  },
  {
    title: 'Content & settings',
    labels: ['App Banner', 'Icons', 'Terms & Conditions', 'Contact Info', 'Profile'],
  },
];

export default function AppLayouts({ children }) {
  const [isOpen, setIsOpen] = useState(true);
  const user = getLocalStorageItem(ELocalStorageKeys.USER) as ILoginData;
  const { t } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const { isLoggedIn } = useLoaderData() as { isLoggedIn: boolean };
  const navigate = useNavigate();
  useEffect(() => {
    const handleResize = () => {
      const mediaQuery = window.matchMedia('(max-width: 768px)');
      setIsOpen(!mediaQuery.matches);
    };
    handleResize();
    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  const handleOverlayClick = () => {
    if (window.innerWidth < 768) {
      setIsOpen(false);
    }
  };

  useEffect(() => {
    if (isLoggedIn) {
      location.pathname;
    } else {
      navigate(ROUTES.LOG_IN);
    }
  }, [isLoggedIn]);

  return (
    <>
      {/* Professional Header */}
      <div className="fixed z-10 w-full border-b border-slate-200 bg-white ltr:md:pl-72 rtl:md:pr-72">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                className="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-100 text-slate-600 transition-colors hover:bg-slate-200 md:hidden"
                onClick={() => setIsOpen(true)}>
                <GoSidebarCollapse size={20} />
              </button>
              <div className="hidden md:block">
                <h1 className="text-xl font-semibold text-slate-900">Kleano Admin</h1>
                <p className="text-sm text-slate-500">Management Dashboard</p>
              </div>
            </div>

            <div className="flex items-center space-x-4">
              <div className="flex items-center">
                <Select
                  defaultValue={i18n.language}
                  onValueChange={(value: 'ar' | 'en') => {
                    changeLangHandler(value);
                  }}>
                  <SelectTrigger className="w-[120px] border-slate-200 bg-slate-50">
                    <SelectValue placeholder="" />
                  </SelectTrigger>
                  <SelectContent className="z-[100]">
                    <SelectGroup>
                      <SelectItem value="en">
                        <div className="flex items-center justify-start gap-2">
                          <span className="text-sm font-medium text-slate-700">English</span>
                        </div>
                      </SelectItem>
                      <SelectItem value="ar">
                        <div className="flex items-center justify-start gap-2">
                          <span className="text-sm font-medium text-slate-700">العربيه</span>
                        </div>
                      </SelectItem>
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </div>
              <div className="hidden sm:block">
                <UserLoginDropDowen name={user?.userName} email={user?.userName} />
              </div>
            </div>
          </div>
        </div>
      </div>
      <AnimatePresence>
        {isOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.5 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="fixed inset-0 z-20  bg-black md:hidden"
              onClick={() => setIsOpen(false)}></motion.div>
            <motion.aside
              initial={{ x: lang === 'ar' ? '100%' : '-100%' }}
              animate={{ x: 0 }}
              exit={{ x: lang === 'ar' ? '100%' : '-100%' }}
              transition={{ type: 'spring', stiffness: 200, damping: 25 }}
              className={classNames(
                'flex shrink-0 grow-0 flex-col border-slate-200 bg-white ltr:border-r rtl:border-l',
                'fixed z-20 h-screen w-72'
              )}>
              {/* Fixed Sidebar Header */}
              <div className="flex-shrink-0 border-b border-slate-200 px-6 py-5">
                <img className="mx-auto w-16" src={kleano_main_logo} alt="Kleano Logo" />
              </div>

              {/* Scrollable Navigation Items */}
              <div className="flex-1 overflow-y-auto scrollbar-hide">
                <div className="px-3 py-4">
                  <div className="space-y-5">
                    {navGroups.map((group) => (
                      <div key={group.title} className="space-y-1">
                        <p className="px-3 pb-1 text-xs font-medium text-slate-400">{group.title}</p>
                        {navItems
                          .filter((item) => group.labels.includes(item.label))
                          .map((item) => (
                            <NavLink
                        to={item.link}
                        key={item.label}
                        onClick={() => handleOverlayClick()}
                        className={({ isActive }): string =>
                          classNames(
                            'flex cursor-pointer items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium capitalize transition-all duration-200',
                            { 'bg-brandTint font-semibold text-primary': isActive },
                            {
                              'text-slate-600 hover:bg-slate-100 hover:text-slate-900':
                                !isActive,
                            }
                          )
                        }>
                        <span className="flex-shrink-0">{item.icon}</span>
                        <span className="truncate">{t(item.label)}</span>
                      </NavLink>
                          ))}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      <div className="min-h-screen bg-background ltr:md:ml-72 rtl:md:mr-72">
        <main className="pt-20">
          <div className="px-6 py-6">{children}</div>
        </main>
      </div>
    </>
  );
}
