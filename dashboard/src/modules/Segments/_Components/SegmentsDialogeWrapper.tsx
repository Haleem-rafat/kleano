import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';

const SegmentsDialogeWrapper = ({
  triggerButtonElement,
  description,
  title,
  children,
  submitButtonElement,
  modal,
}: {
  triggerButtonElement: JSX.Element;
  description?: string;
  title?: string;
  modal: boolean;
  children: JSX.Element;
  submitButtonElement?: JSX.Element;
}) => {
  return (
    <div>
      <Dialog modal={modal}>
        <DialogTrigger asChild>{triggerButtonElement}</DialogTrigger>
        <DialogContent className="min-w-fit">
          <DialogHeader>
            <DialogTitle>{title}</DialogTitle>
            <DialogDescription>{description}</DialogDescription>
          </DialogHeader>
          {children}
          <DialogFooter>{submitButtonElement}</DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default SegmentsDialogeWrapper;
