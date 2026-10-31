import { useTranslation } from 'react-i18next';
import { useRef, useState } from 'react';
import { ControllerRenderProps, FieldValues } from 'react-hook-form';

import { Button } from '@UI/Index';
import { FormItem, FormLabel } from '@shadecn/components/ui/form';
import classNames from 'classnames';
import { Avatar, AvatarImage } from '@/shadecn/components/ui/avatar';

interface IMainCoverUploadProps {
  title?: string;
  hint?: string;
  textButton: JSX.Element | string;
  field?: ControllerRenderProps<FieldValues, string>;
  disabled?: boolean;
}

export default function ImgUpload({
  field,
  textButton,
  title,
  disabled,
}: IMainCoverUploadProps) {
  const { t } = useTranslation();
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const [isHovering, setIsHovering] = useState(false);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
      field?.onChange(file);
    }
  };

  const openFileSelector = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  return (
    <FormItem className={classNames({ 'pointer-events-none opacity-50': disabled })}>
      {title && <FormLabel className="text-text-600 text-sm font-semibold">{title}</FormLabel>}
      <div className="relative flex flex-col items-center gap-2">
        <Avatar
          className="flex h-40 w-full items-center justify-center rounded-lg border bg-neutral-100"
          onMouseEnter={() => setIsHovering(true)}
          onMouseLeave={() => setIsHovering(false)}>
          {imagePreview || field.value ? (
            <>
              <AvatarImage src={imagePreview || field.value} className="object-cover" />
              {isHovering && (
                <button
                  type="button"
                  className="absolute inset-0 flex cursor-pointer items-center justify-center bg-black/50 text-white"
                  onClick={openFileSelector}>
                  <span>{t('Change Image')}</span>
                </button>
              )}
            </>
          ) : (
            <Button
              className="h-0 w-fit p-0 text-sm text-primary underline"
              type="button"
              onClick={openFileSelector}>
              {textButton}
            </Button>
          )}
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            onChange={handleImageUpload}
            className="hidden"
            id="imageUpload"
          />
        </Avatar>
      </div>
    </FormItem>
  );
}
