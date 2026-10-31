import { Button } from '@shadecn/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@shadecn/components/ui/dialog';
import { t } from 'i18next';

interface ICitiesDialogeProps {
  buttonElement: JSX.Element;
  description?: string;
  title: string;
  children: JSX.Element;
  handler?: () => void;
}

const CitiesDialoge = ({
  buttonElement,
  description,
  title,
  children,
  handler,
}: ICitiesDialogeProps) => {
  return (
    <div>
      <Dialog>
        <DialogTrigger asChild>{buttonElement}</DialogTrigger>
        <DialogContent onClick={(e) => e.stopPropagation()} className="min-w-fit">
          <DialogHeader>
            <DialogTitle>{title}</DialogTitle>
            {description && <DialogDescription>{description}</DialogDescription>}
          </DialogHeader>
          {children}
          <DialogFooter>
            {handler && (
              <Button onClick={handler} type="submit">
                {t('applyEdit')}
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default CitiesDialoge;
