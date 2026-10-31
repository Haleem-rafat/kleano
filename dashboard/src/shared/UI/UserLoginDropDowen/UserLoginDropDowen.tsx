import { useTranslation } from 'react-i18next';
import authService from '@services/auth.service';
import MainAvatar from '@UI/MainAvatar/MainAvatar';
import { IoIosArrowDown, IoMdSettings } from 'react-icons/io';
import { TbLogout2 } from 'react-icons/tb';
import { useNavigate } from 'react-router-dom';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@shadecn/components/ui/dropdown-menu';
import { ROUTES } from '@constants/routes';

interface IUserLoginDropDowenProps {
  name: string;
  email: string;
  imag?: string;
}

export default function UserLoginDropDowen({
  name,
  imag,
  email,
}: IUserLoginDropDowenProps): JSX.Element {
  const { t } = useTranslation();
  const navigate = useNavigate();
  return (
    <div className="flex items-center">
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <div className="flex cursor-pointer items-center gap-3 rounded-lg px-3 py-2 transition-colors hover:bg-slate-100">
            <MainAvatar src={imag} size="lg" name={name} />
            <div className="hidden text-left sm:block">
              <p className="text-sm font-semibold capitalize text-slate-900">{name}</p>
              <p className="text-xs text-slate-500">{email}</p>
            </div>
            <IoIosArrowDown className="h-4 w-4 text-slate-500" />
          </div>
        </DropdownMenuTrigger>
        <DropdownMenuContent className="w-56 border-slate-200 bg-white shadow-lg">
          <DropdownMenuItem
            key="Settings"
            className="cursor-pointer px-4 py-3 text-sm transition-colors hover:bg-slate-50"
            onClick={() => navigate(ROUTES.PROFILE)}>
            <div className="flex items-center gap-3">
              <IoMdSettings className="h-4 w-4 text-slate-600" />
              <span className="text-slate-700">{t('Settings')}</span>
            </div>
          </DropdownMenuItem>
          <DropdownMenuItem
            key="Log out"
            className="cursor-pointer px-4 py-3 text-sm transition-colors hover:bg-slate-50"
            onClick={() => {
              window.location.reload();
              authService.logout();
            }}>
            <div className="flex items-center gap-3">
              <TbLogout2 className="h-4 w-4 text-slate-600" />
              <span className="text-slate-700">{t('Sign out')}</span>
            </div>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
}
