import kleano_main_logo from '@assets/img/kleano-main-logo.png';
import auth_photo from '@assets/img/auth-photo.jpg';

export default function AuthLayout({ children }) {
  return (
    <div className="grid min-h-screen bg-background lg:grid-cols-2">
      <div className="relative hidden overflow-hidden lg:block">
        <img className="absolute inset-0 h-full w-full object-cover" src={auth_photo} alt="" />
      </div>
      <main className="flex flex-col items-center justify-center gap-8 px-4 py-10">
        <img className="w-32" src={kleano_main_logo} alt="Kleano" />
        {children}
      </main>
    </div>
  );
}
