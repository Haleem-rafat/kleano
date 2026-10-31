import { useState } from 'react';
import { IoClose, IoExpandOutline } from 'react-icons/io5';
import { Dialog, DialogContent, DialogHeader } from '@shadecn/components/ui/dialog';
import { Button } from '@shadecn/components/ui/button';

interface ImageModalProps {
  src: string;
  alt: string;
  className?: string;
  thumbnailClassName?: string;
  showExpandIcon?: boolean;
  fallbackText?: string;
}

export default function ImageModal({
  src,
  alt,
  className = 'h-20 w-20 rounded-lg border border-gray-200 object-cover cursor-pointer hover:opacity-80 transition-opacity',
  thumbnailClassName = '',
  showExpandIcon = true,
  fallbackText = 'No image available',
}: ImageModalProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [imageError, setImageError] = useState(false);

  const handleImageClick = () => {
    if (!imageError) {
      setIsOpen(true);
    }
  };

  const handleImageError = () => {
    setImageError(true);
  };

  const handleClose = () => {
    setIsOpen(false);
  };

  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      handleImageClick();
    }
  };

  if (imageError || !src) {
    return (
      <div
        className={`${className} ${thumbnailClassName} flex items-center justify-center bg-gray-100 text-sm text-gray-500`}>
        {fallbackText}
      </div>
    );
  }

  return (
    <>
      {/* Thumbnail Image */}
      <div className="group relative">
        <img
          src={src}
          alt={alt}
          className={`${className} ${thumbnailClassName}`}
          onClick={handleImageClick}
          onError={handleImageError}
          onKeyDown={handleKeyDown}
          tabIndex={0}
          role="button"
          aria-label={`View larger image of ${alt}`}
        />
      </div>

      {/* Modal */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-h-[90vh] border-0 bg-black/95 p-0 sm:max-w-5xl">
          <DialogHeader className="absolute right-4 top-4 z-10">
            <Button
              variant="ghost"
              size="sm"
              onClick={handleClose}
              className="rounded-full p-2 text-white hover:bg-white/20"
              aria-label="Close modal">
              <IoClose className="h-6 w-6" />
            </Button>
          </DialogHeader>

          <div className="flex min-h-[50vh] items-center justify-center p-4">
            <img
              src={src}
              alt={alt}
              className="h-[80vh] w-full rounded-lg object-contain shadow-2xl"
              onClick={handleClose}
            />
          </div>

          {/* Image Info */}
          <div className="absolute bottom-4 left-4 right-4 rounded-lg bg-black/50 p-3 text-white">
            <p className="text-sm font-medium">{alt}</p>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
