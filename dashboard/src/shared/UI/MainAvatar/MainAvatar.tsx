import { Avatar, AvatarFallback, AvatarImage } from '@/shadecn/components/ui/avatar';
import { cn } from '@/shadecn/lib/utils';

interface IProps {
  src: string;
  withImagePlaceholder?: boolean;
  name?: string;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl' | '3xl' | '4xl';
  className?: string;
}

export default function MainAvatar({
  withImagePlaceholder = false,
  src = withImagePlaceholder ? null : null,
  name = 'Z',
  size = 'md',
}: IProps): React.ReactElement {
  const getFirstLetters = (text: string): string => {
    const wordArr = text.split(' ');
    if (wordArr.length === 1) {
      // Case where there is only one word in the name
      return `${text.charAt(0).toLocaleUpperCase()}`;
    } else if (wordArr.length >= 2) {
      // Case where there are two or more words in the name
      const firstInitial = wordArr[0].charAt(0).toLocaleUpperCase();
      const secondInitial = wordArr[1]?.charAt(0).toLocaleUpperCase() || '';

      return `${firstInitial}${secondInitial}`;
    } else {
      // Handle other cases, for example, an empty string
      return '';
    }
  };
  return (
    <Avatar
      className={cn('border-primary-Variant border-2', {
        'h-5 w-5': size === 'xs',
        'h-6 w-6': size === 'sm',
        'h-8 w-8': size === 'md',
        'h-10 w-10': size === 'lg',
        'h-12 w-12': size === 'xl',
        'h-14 w-14': size === '2xl',
        'h-16 w-16': size === '3xl',
        'h-40 w-40': size === '4xl',
      })}>
      <AvatarImage src={src} className="object-cover" />
      <AvatarFallback className="bg-white text-sm font-semibold text-slate-700">
        {getFirstLetters(name)}
      </AvatarFallback>
    </Avatar>
  );
}
