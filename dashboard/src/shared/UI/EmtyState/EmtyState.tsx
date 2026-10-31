import { Button } from '@UI/Index';
import classNames from 'classnames';
import { useTranslation } from 'react-i18next';
import { ReactSVG } from 'react-svg';
import emty_state from '@assets/icons/emty-state.svg';

interface IEmtyStateProps {
  srcImg?: string;
  title?: string;
  pragraph?: string;
  textButton?: string;
  buttonAction?: () => void;
  buttonVariant?: 'primary' | 'secondary' | 'tertiary' | 'danger' | 'success';
  className?: string;
}

export default function EmtyState({
  srcImg,
  title,
  pragraph,
  textButton,
  buttonAction,
  buttonVariant,
  className,
}: IEmtyStateProps): JSX.Element {
  const { t } = useTranslation();
  return (
    <div className={classNames(className, 'mt-auto flex flex-col items-center py-36')}>
      <ReactSVG src={srcImg || emty_state} />
      <p className="text-black-darker pt-6 font-bold">{title || t('emty_stat')}</p>
      <p className="text-gray-light pt-2 text-center text-sm">{pragraph}</p>
      {textButton && (
        <div className="pt-4">
          <Button onClick={buttonAction} variant={buttonVariant}>
            {textButton}
          </Button>
        </div>
      )}
    </div>
  );
}
